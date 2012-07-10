class ProcedureSweeper < PathwaysSweeper
  observe Procedure
  
  def expire_self(entity)
    expire_fragment procedure_path(entity)
  end 
  
  def add_to_lists(procedure)
    #expire all specializations that the procedure is in
    @specializations << procedure.specializations_including_in_progress.map { |s| s.id }
    
    #expire all child procedures of this procedure
    @procedures << procedure.children.map{ |p| p.id }
    
    #expire all specialists that perform this or any child procedure
    @specialists << procedure.all_specialists.map{ |p| p.id }
    
    #expire all clinics that the specialist attends
    @clinics << procedure.all_clinics.map{ |c| c.id }
  end
end