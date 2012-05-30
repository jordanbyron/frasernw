module FrontHelper
  
  def latest_events(max_events)
    events = []
    Version.order("id desc").each do |version|
      event = interesting_event(version)
      events << event if event.present?
      return events if events.length >= max_events
    end
    return events
  end
  
  def interesting_event(version)
    
    return false if version.item.blank?
      
    if version.item_type == "Specialist"
      
      specialist = version.item
      return false if specialist.blank?
      
      if version.event == "create" && specialist.accepting_new_patients?
        
        #new specialist that is accepting patients
        
        if specialist.city.present? 
          return "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is accepting patients in #{specialist.city}. #{version.id}".html_safe
        else 
          return "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is accepting patients. #{version.id}".html_safe
        end
      
      elsif version.event == "update"
      
        if specialist.retired?
          
          return false if version.previous.blank? || version.previous.reify.blank?
          return false if version.previous.reify.retired? #retired status hasn't changed
          
          #newly retired
          
          return "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired. #{version.id}".html_safe
          
        elsif specialist.retiring?
          
          return false if version.previous.blank? || version.previous.reify.blank?
          return false if version.previous.reify.retiring? #retiring status hasn't changed
          
          return "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{specialist.unavailable_from.strftime('%B %d, %Y')}. #{version.id}".html_safe          
          
        end
      
      end
      
    elsif version.item_type == "Clinic"
      
      clinic = version.item
      return false if clinic.blank?
      
      if version.event == "create" && clinic.accepting_new_patients?
        
        #new clinic
      
        if clinic.city.present?
          return "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is accepting patients in #{clinic.city}. #{version.id}".html_safe
        else
          return "#{link_to clinic.name, clinic_path(clinic), :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) is accepting patients. #{version.id}".html_safe
        end
      
      end
      
    elsif version.item_type == "Attendance"
      
      attendance = version.item
      return false if attendance.blank? || attendance.specialist.blank? || attendance.clinic.blank?
    
      specialist = attendance.specialist;
      clinic = attendance.clinic;
      
      if version.event == "create"
        
        #new specialist / clinic association
      
        return "#{link_to specialist.name, specialist_path(specialist), :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) now works at #{link_to clinic.name, clinic_path(clinic), :class => 'ajax'}. #{version.id}".html_safe
      
      end
    end
  end
  
end
