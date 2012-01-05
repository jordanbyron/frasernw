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
  
  def listed_procedure(procedure)
    "#{procedure.name} (#{procedure.specialists.length})"
  end
  
  def specialists_procedures(specialist)
    list = ""
    specialist.procedure_specializations.each do |ps|
      list += ps.procedure.name + (specialist.procedure_specializations.last == ps ? '' : ", ")
    end
    list
  end
  
  alias :clinics_procedures :specialists_procedures
  
  def procedure_ancestry(specialist)
    result = {}
  
    specialist.procedure_specializations.each do |ps| 
      temp = { ps => {} }
      while ps.parent
        temp = { ps.parent => temp }
        ps = ps.parent
      end
      result.merge!(temp) { |key, a, b| a.merge(b) }
    end
    
    return result
  end
  
  def compressed_procedures(specialist)
    return compressed_procedures_output( procedure_ancestry(specialist), "" )[0..-2]
  end
  
  def compressed_procedures_output(items, prefix)
    result = ""
    items.map do |item, sub_items|
      new_prefix = prefix.blank? ? item.procedure.name : prefix + " > " + item.procedure.name
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
      result += "<li>" + item.procedure.name + "</li>"
      result += compressed_procedures_indented_output(sub_items)
    end
    result += "</ul>"
    result
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
  
  def ancestry_options(items, &block)
    return ancestry_options(items){ |i| "#{'-' * i.depth} #{i.name}" } unless block_given?
    
    result = []
    items.map do |item, sub_items|
      result << [yield(item), item.id]
      #this is a recursive call:
      result += ancestry_options(sub_items, &block)
    end
    result
  end
  
end
