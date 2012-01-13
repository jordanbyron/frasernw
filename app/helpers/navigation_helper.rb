module NavigationHelper
  
  def add_procedure_specialization(block_id, ps, children)
    
    output = "<ul id='#{block_id}', title='#{ps.procedure.name}'>"
    
    #make the list of the children of this block, with links to either sub-procedures or the list of specialists in the procedure (depending on whether procedure has children)
    children.each do |child_ps, child_children|
      next if not child_ps.procedure.specialization_level
      
      if child_children.empty?
        output += "<li><a href=\"#p_#{child_ps.procedure.id}\" onclick=\"javascript:linkto('#{procedure_path(child_ps.procedure)}')\">#{child_ps.procedure.name}</a></li>"
      else
        output += "<li><a href=\"##{block_id}_#{child_ps.procedure.id}\" onclick=\"javascript:linkto('#{procedure_path(child_ps.procedure)}')\">#{child_ps.procedure.name}</a></li>"
      end
    end
    
    output += "</ul>"
    
    #if there are children, recursively make the blocks for them
    children.each do |child_ps, child_children|
      next if not child_ps.procedure.specialization_level
      next if child_children.empty?

      child_block_id = "#{block_id}_#{child_ps.procedure.id}"
      output += add_procedure_specialization(child_block_id, child_ps, child_children)
    end
    
    return output
  end

end
