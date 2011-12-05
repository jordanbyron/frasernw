module ApplicationHelper  
  def name_for(user)
    unless user.name.blank?
      if user.name.split(' ').length > 1
        user.name.split[0] + ' ' + user.name.split[1][0,1] + '.'
      else
        user.name
      end
    else
      user.login
    end
  end
  
  def listed_specialist(specialist)
    "#{specialist.firstname} #{specialist.lastname} - #{specialist.city}"
  end
  def listed_procedure(procedure)
    "#{procedure.name} (#{procedure.specialists.length})"
  end
  
  def specialists_procedures(specialist)
    list = ""
    specialist.procedures.each do |procedure|
      list += procedure.name + (specialist.procedures.last == procedure ? '' : ", ")
    end
    list
  end
  
  alias :clinics_procedures :specialists_procedures
  
  def procedure_ancestry(specialist)
    specialist.procedures.arrange(:order => "name")
  end
  
  def compressed_procedures(specialist)
    return compressed_procedures_output( procedure_ancestry(specialist), "" )[0..-2]
  end
  
  def compressed_procedures_output(items, prefix)
    result = ""
    items.map do |item, sub_items|
      new_prefix = prefix.blank? ? item.name : prefix + " > " + item.name
      result += new_prefix + ", " + compressed_procedures_output(sub_items, new_prefix)
    end
    result
  end
  
  def compressed_procedures_indented(specialist)
    return compressed_procedures_indented_output( procedure_ancestry(specialist) ) 
  end
  
  def compressed_procedures_indented_output(items)
    return "" if items.empty?
    result = "<ul>"
    items.map do |item, sub_items|
      result += "<li>" + item.name + "</li>"
      result += compressed_procedures_indented_output(sub_items)
    end
    result += "</ul>"
    result
  end
  
  def compressed_ancestry(procedure)
    result = ""
    if procedure.parent
       result += compressed_ancestry(procedure.parent) + " > "
    end
    result += procedure.name
    result
  end
  
  def compressed_clinics(clinics)
    output = ''
    clinics.each do |clinic|
      output += (clinic.name + ', ')
    end
    output.gsub(/\,\ $/,'')
  end
  
end
