module FrontHelper
  
  def latest_events(max_automated_events, divisions)
    
    manual_events = {}
    automated_events = {}
    
    NewsItem.specialist_clinic_in_divisions(divisions).each do |news_item|
      item = news_item.title.present? ? BlueCloth.new(news_item.title + ". " + news_item.body).to_html : BlueCloth.new(news_item.body).to_html
      
      manual_events["NewsItem_#{news_item.id}"] = ["#{news_item.start_date || news_item.end_date}", item.html_safe]
    end
    
    Version.includes(:item).order("id desc").where("item_type in (?)", ["Specialist", "SpecialistOffice", "ClinicLocation"]).limit(2000).each do |version|
    
      next if version.item.blank?
      break if automated_events.length >= max_automated_events
      
      begin
      
        if version.item_type == "Specialist"
          
          specialist = version.item
          specialist_cities = specialist.cities_for_front_page.flatten.uniq

          next if specialist.blank? || specialist.in_progress
          next if current_user.does_not_share_local_referral_city?(specialist_cities) 

          if version.event == "update"
          
            if specialist.moved_away?
              
              next if version.reify.blank?
              next if version.reify.moved_away? #moved away status hasn't changed
              next if (version.reify.unavailable_from < Date.today - 11.months)
              
              #newly moved away
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away.".html_safe]
              
            elsif specialist.retired?
              
              next if version.reify.blank?
              next if version.reify.retired? #retired status hasn't changed
              next if specialist.id == 242
              
              #newly retired
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired.".html_safe]
              
            elsif specialist.retiring?
              
              next if version.reify.blank?
              next if version.reify.retiring? #retiring status hasn't changed
              current_specialist = Specialist.find(specialist.id);
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{current_specialist.unavailable_from.to_s(:long_ordinal)}.".html_safe]
              
            end
          
          end
          
        elsif version.item_type == "SpecialistOffice"
        
          specialist_office = version.item
          next if specialist_office.specialist.blank? || specialist_office.specialist.in_progress
          
          specialist = specialist_office.specialist
          
          specialist_cities = specialist.cities_for_front_page.flatten.uniq
          next if current_user.does_not_share_local_referral_city?(specialist_cities)

          if (["create", "update"].include? version.event) && specialist.accepting_new_patients? && specialist_office.opened_recently?
            
            if (version.event == "update")
                next if version.reify.blank?
                next if version.reify.opened_recently? #opened this year status hasn't changed)
            end
            
            if specialist_office.city.present?
              automated_events["Specialist_#{specialist.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{specialist_office.city.name} and is accepting new referrals.".html_safe]
            else
              automated_events["Specialist_#{version.item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals.".html_safe]
            end
            
          end
          
        elsif version.item_type == "ClinicLocation"
        
          clinic_location = version.item
          next if clinic_location.clinic.blank? || clinic_location.clinic.in_progress #devnoteperformance: in_progress query creates 13 ActiveRecord Selects
          next if current_user.does_not_share_local_referral_city?(clinic_location.clinic.cities)
          clinic = clinic_location.clinic
          
          if (["create", "update"].include? version.event) && clinic.accepting_new_patients? && clinic_location.opened_recently?
            
            if (version.event == "update")
                next if version.reify.blank?
                next if version.reify.opened_recently? #opened this year status hasn't changed)
            end
            
            if clinic_location.city.present?
              automated_events["Clinic_#{version.item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{clinic_location.city.name} and is accepting new referrals.".html_safe]
            else
              automated_events["Clinic_#{version.item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals.".html_safe]
            end
            
          end
          
        end
      rescue Exception => exc
        #automated_events['error_error'] = ["ding", exc]
        next
      end
    end
    
    #mix in the news updates with the automatic updates
    return automated_events.merge(manual_events).values.sort{ |a, b| b[0] <=> a[0] }.map{ |x| x[1] }
  end
end
