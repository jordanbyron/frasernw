module FrontHelper
  
  def latest_events(max_events)
    
    events = {}
        
    Version.order("id desc").where("item_type = ? OR item_type = ? OR item_type = ? OR item_type = ? OR item_type = ? OR item_type = ?", "Specialist", "Clinic", "Attendance", "Schedule", "Address", "SpecialistOffice").limit(500).each do |version|
    
      next if version.item.blank?
      break if events.length >= max_events
      
      begin
      
        if version.item_type == "Specialist"
          
          specialist = version.item
          next if specialist.blank?
          
          if version.event == "create" && specialist.accepting_new_patients? && specialist.opened_this_year?
            
            #new specialist that is accepting patients
            
            if specialist.city.present? 
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is accepting patients in #{specialist.city}.".html_safe
            else 
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is accepting patients.".html_safe
            end
          
          elsif version.event == "update"
          
            if specialist.moved_away?
              
              next if version.previous.blank? || version.previous.reify.blank?
              next if version.previous.reify.moved_away? #moved away status hasn't changed
              
              #newly moved away
              
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away.".html_safe
              
            elsif specialist.retired?
              
              next if version.previous.blank? || version.previous.reify.blank?
              next if version.previous.reify.retired? #retired status hasn't changed
              
              #newly retired
              
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired.".html_safe
              
            elsif specialist.retiring?
              
              next if version.previous.blank? || version.previous.reify.blank?
              next if version.previous.reify.retiring? #retiring status hasn't changed
              
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{specialist.unavailable_from.strftime('%B %d, %Y')}.".html_safe
              
            end
          
          end
          
        elsif version.item_type == "Clinic"
          
          clinic = version.item
          next if clinic.blank?
          
          if version.event == "create" && clinic.accepting_new_patients? && clinic.opened_this_year?
            
            #new clinic
          
            if clinic.city.present?
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is accepting patients in #{clinic.city}.".html_safe
            else
              events["#{version.item_type}_#{version.item.id}"] = "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is accepting patients.".html_safe
            end
          
          end
          
        elsif version.item_type == "Attendance"
          
          attendance = version.item
          next if attendance.blank? || attendance.specialist.blank? || attendance.clinic.blank?
        
          specialist = attendance.specialist;
          clinic = attendance.clinic;
          
          if version.event == "create"
            
            #new specialist / clinic association
          
            events["#{version.item_type}_#{specialist.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) now works at the #{link_to clinic.name, clinic_path(clinic), :class => 'ajax'}.".html_safe
          
          end
          
        elsif version.item_type == "Schedule"
          
          schedule = version.item
          next if schedule.blank? || !schedule.scheduled? || schedule.schedulable.blank?
        
          schedulable = schedule.schedulable
          
          if version.event == "create" || version.event == "update"
          
            events["Clinic_#{schedulable.id}"] = "The schedule for the #{link_to schedulable.name, url_for(schedulable), :class => 'ajax'} (#{schedulable.specializations.map{ |s| s.name }.to_sentence}) is now #{schedule.days_and_hours.to_sentence}.".html_safe
          
          end
          
        elsif version.item_type == "Address" && false
          
          address = version.item
          next if address.blank? || address.locations.blank?
          
          location = address.locations.first
          next if location.blank?
          
          next if version.previous.blank? || version.previous.reify.blank?
          old_address = version.previous.reify
          
          next if old_address.short_address == address.short_address #hasn't changed
          
          if version.event == "update"
            
            if location.locatable.is_a?(Office)
          
              events["#{version.item_type}_#{version.item.id}"] = "The address for #{location.locatable.specialists.map{ |s| link_to s.name, specialist_path(s), :class => 'ajax' }.to_sentence} is now #{address.short_address}.".html_safe
              
            else
              
              events["#{version.item_type}_#{version.item.id}"] = "The address for #{location.locatable.name} is now #{address.short_address}.".html_safe
            
            end
          
          end
          
        elsif version.item_type == "SpecialistOffice" && false
        
          specialist_office = version.item
          next if specialist_office.blank? || specialist_office.specialist.blank? || specialist_office.office.blank?
          
          specialist = specialist_office.specialist
          office = specialist_office.office
            
          next if office.short_address.blank?
          
          if version.event == "create" || version.event == "update"
            
            if office.specialists.length > 1
              
              events["Specialist_#{specialist.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence }) now works in an office at #{office.short_address}. with #{office.specialists.reject{ |s| specialist.id == s.id }.map{ |s| link_to s.name, specialist_path(s), :class => 'ajax' }.to_sentence}.".html_safe
            
            else
              
              events["Specialist_#{specialist.id}"] = "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence }) now works in an office at #{office.short_address}.".html_safe
            
            end
          end
        end
      rescue Exception => exc
        #events['error'] = exc
        next
      end
    end
    
    return events.values
  end
  
end
