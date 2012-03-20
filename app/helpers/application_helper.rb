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
      temp = { ps => {} }
      next if ps.classification != classification
      while ps.parent
        temp = { ps.parent => temp }
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
    a.sort!{ |x, y| x[:parent].procedure.name <=> y[:parent].procedure.name }
    a.each do |entry|
      sort_array_of_hashes( entry[:children] )
    end
  end
  
  def compressed_procedures_indented(specialist_or_clinic, classification)
    return compressed_procedures_indented_output( procedure_ancestry(specialist_or_clinic, classification), specialist_or_clinic ) 
  end
  
  def compressed_procedures_indented_output(items, root)
    count = 0
    return "", 0 if items.empty?
    result = "<ul>"
    items.each do |item|
      count += 1
      result += "<li>"
      result += item[:parent].procedure.name
      investigation = item[:parent].investigation(root)
      if investigation and investigation.length > 0
        result += ": #{investigation}"
      end
      result += "</li>"
      child_result, child_count = compressed_procedures_indented_output(item[:children], root)
      result += child_result
      count += child_count                                       
    end
    result += "</ul>"
    return result, count
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
  
  def capitalize_first_letter(phrase)
    phrase.slice(0,1).capitalize + phrase.slice(1..-1)
  end
  
end
