module ApplicationHelper
  
  def specialists_procedures(specialist)
    list = ""
    specialist.procedure_specializations.each do |ps|
      list += ps.procedure.name + (specialist.procedure_specializations.last == ps ? '' : ", ")
    end
    list
  end
  
  alias :clinics_procedures :specialists_procedures
  
  def procedure_ancestry(specialist_or_clinic_or_specialization, classification)
    result = {}
  
    specialist_or_clinic_or_specialization.procedure_specializations.each do |ps| 
      temp = { ps.procedure => {} }
      next if ps.classification != classification
      while ps.parent
        temp = { ps.parent.procedure => temp }
        ps = ps.parent
      end
      result.merge!(temp) { |key, a, b| a.merge(b) }
    end
    
    return sort_array_of_hashes( hash_to_array( result ) )
  end
  
  def hash_to_array( h )
    a = []
    h.each do |k,v|
      a << {:parent => k, :children => hash_to_array( v )}
    end
    a
  end
  
  def sort_array_of_hashes( a )
    a.sort!{ |x, y| x[:parent].name <=> y[:parent].name }
    a.each do |entry|
      sort_array_of_hashes( entry[:children] )
    end
  end
  
  def compressed_procedures_indented(specialist_or_clinic, classification)
    return compressed_procedures_indented_output( procedure_ancestry(specialist_or_clinic, classification), specialist_or_clinic ) 
  end
  
  def compressed_procedures_indented_output(items, root)
    return "", 0, false if items.empty?
    count = 0
    has_investigation = false
    result = "<ul>"
    items.each do |item|
      count += 1
      result += "<li>"
      result += "<strong><a class='ajax' href='#{procedure_path(item[:parent])}'>#{item[:parent].name}</a></strong>"
      investigation = item[:parent].procedure_specializations.map{ |ps| ps.investigation(root) }.reject{ |i| i.blank? }.map{ |i| i.punctuate }.join(' ');
      investigation = investigation.strip_period if investigation.present?
      if investigation and investigation.length > 0
        result += " (#{investigation})"
        has_investigation = true
      end
      if !item[:children].empty?
        child_results = []
        item[:children].each do |child|
          count += 1
          child_investigation = child[:parent].procedure_specializations.map{ |ps| ps.investigation(root) }.reject{ |i| i.blank? }.map{ |i| i.punctuate }.join(' ');
          child_investigation = child_investigation.strip_period if child_investigation.present?
          if child_investigation && child_investigation.strip.length != 0
            has_investigation = true
            child_results << "<a class='ajax' href='#{procedure_path(child[:parent])}'>#{child[:parent].name}</a> (#{child_investigation})"
          else
            child_results << "<a class='ajax' href='#{procedure_path(child[:parent])}'>#{child[:parent].name}</a>"
          end
        end
        result += ": #{child_results.to_sentence}"
      end
      result += "</li>"         
    end
    result += "</ul>"
    return result, count, has_investigation
  end
  
  def compressed_ancestry(procedure_specialization)
    result = ""
    while procedure_specialization.parent
      result = " > " + procedure_specialization.parent.procedure.name + result
      procedure_specialization = procedure_specialization.parent
    end
    procedure_specialization.specialization.name + result
  end
  
  def compressed_clinics(clinics)
    output = ''
    clinics.each do |clinic|
      output += (clinic.name + ', ')
    end
    output.gsub(/\,\ $/,'')
  end
  
  def ancestry_options(items, parent = "")
    result = []
    items.map do |item, sub_items|
      item_text = parent.empty? ? "#{item.procedure.name}" : "#{parent} #{item.procedure.name}"
      result << [ item_text, item.id]
      #this is a recursive call:
      result += ancestry_options(sub_items, item_text)
    end
    result
  end
  
  def current_user_is_admin?
    return (current_user and current_user.admin?)
  end
  
  def current_user_is_super_admin?
    return (current_user and current_user.super_admin?)
  end
  
  def current_user_id
    if current_user
      return current_user.id
    else
      return -1
    end
  end

  def current_user_type_mask
    if current_user
      return current_user.admin? ? 0 : current_user.type_mask
    else
      return -1
    end
  end
  
  def current_user_divisions
    if current_user
      return current_user.divisions
    else
      return []
    end
  end
  
  def default_owner
    return User.find(10)
  end
  
end
