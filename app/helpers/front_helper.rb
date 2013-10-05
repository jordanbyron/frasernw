module FrontHelper
  
  def latest_events(max_automated_events, divisions)
    
    manual_events = {}
    automated_events = {}
    
    NewsItem.specialist_clinic_in_divisions(divisions).each do |news_item|
      manual_events["NewsItem_#{news_item.id}"] = ["#{news_item.start_date || news_item.end_date}", "#{BlueCloth.new(news_item.title + ". " + news_item.body).to_html}".html_safe]
    end
    
    Version.order("id desc").where("item_type = (?) OR item_type = (?)", "Specialist", "Clinic").limit(1000).each do |version|
    
      next if version.item.blank?
      break if automated_events.length >= max_automated_events
      
      begin
      
        if version.item_type == "Specialist"
          
          specialist = version.item
          next if specialist.blank? || specialist.in_progress_for_divisions(specialist.divisions) || (specialist.divisions & divisions).blank?
          
          if version.event == "create" && specialist.accepting_new_patients? && specialist.opened_this_year?
            
            #new specialist that is accepting patients
            
            if specialist.city.present? 
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients in #{specialist.city}.".html_safe]
            else 
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients.".html_safe]
            end
          
          elsif version.event == "update"
          
            if specialist.moved_away?
              
              next if version.reify.blank?
              next if version.reify.moved_away? #moved away status hasn't changed
              
              #newly moved away
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away.".html_safe]
              
            elsif specialist.retired?
            
              next if version.reify.blank?
              next if version.reify.retired? #retired status hasn't changed
              
              #newly retired
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired.".html_safe]
              
            elsif specialist.retiring?
            
              next if version.reify.blank?
              next if version.reify.retiring? #retiring status hasn't changed
              
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{specialist.unavailable_from.strftime('%B %d, %Y')}.".html_safe]
              
            elsif specialist.accepting_new_patients? && specialist.opened_this_year?
            
              next if version.reify.blank?
              next if version.reify.opened_this_year? #opened this year status hasn't changed
              
              if specialist.city.present?
                automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients in #{specialist.city}.".html_safe]
                else
                automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients.".html_safe]
              end
              
            end
          
          end
          
        elsif version.item_type == "Clinic"
          
          clinic = version.item
          next if clinic.blank? || clinic.in_progress_for_divisions(clinic.divisions) || (clinic.divisions & divisions).blank?
          
          if (version.event == "create" || version.event == "update") && clinic.accepting_new_patients? && clinic.opened_this_year?
            
            if version.event == "update"
              
              next if version.reify.blank?
              next if version.reify.opened_this_year? #opened this year status hasn't changed
              
            end
            
            #new clinic
          
            if clinic.cities.present?
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients in #{clinic.cities.to_sentence}.".html_safe]
            else
              automated_events["#{version.item_type}_#{version.item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is recently opened and accepting patients.".html_safe]
            end
          
          end
        end
      rescue Exception => exc
        #events['error'] = exc
        next
      end
    end
    
    #mix in the news updates with the automatic updates
    return automated_events.merge(manual_events).values.sort{ |a, b| b[0] <=> a[0] }.map{ |x| x[1] }
  end
  
end
