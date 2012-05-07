class SpecializationSweeper < PathwaysSweeper
  observe Specialization
  
  def expire_self
    expire_fragment :controller => 'specializations', :action => 'show'
  end 
  
  def add_to_lists(specialization)
    #expire all procedures that are in the specialization
    @procedures << specialization.procedures.map{ |p| p.id }
    
    #expire all specialists that are in the specialization
    @specialists << specialization.specialists.map{ |s| s.id }
    
    #expire all clinics that are in the specialization
    @clinics << specialization.clinics.map{ |c| c.id }
    
    #expire all hospitals the specialist has priviledges at
    @hospitals << Hospital.all.map{ |h| h.id }
    
    #expire all languages the specialist speaks
    @languages << Language.all.map{ |l| l.id }
  end
end