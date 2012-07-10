class SpecialistSweeper < PathwaysSweeper
  observe Specialist
  
  def expire_self(entity)
    expire_fragment specialist_path(entity)
  end 
  
  def add_to_lists(specialist)
    #expire all specialization that the specialist is in
    @specializations << specialist.specializations_including_in_progress.map { |s| s.id }
    
    #expire all procedures that the specialist performs
    @procedures << specialist.procedures.map{ |p| p.id }
    
    #expire all specialist that the specialist works with
    specialist.offices.each do |o|
      o.specialists.each do |s|
        next if s.id == specialist.id
        @specialists << s.id
      end
    end
    
    #expire all clinics that the specialist attends
    @clinics << specialist.clinics.map{ |c| c.id }
    
    #expire all hospitals the specialist has priviledges at
    @hospitals << specialist.hospitals.map{ |h| h.id }
    
    #expire all languages the specialist speaks
    @languages << specialist.languages.map{ |l| l.id }
  end
end