class HospitalSweeper < PathwaysSweeper
  observe Hospital
  
  def expire_self
    expire_fragment :controller => 'hospitals', :action => 'show'
  end 
  
  def add_to_lists(hospital)
    #expire all specialization (they list hospitals)
    @specializations << Specialization.all.map { |s| s.id }
    
    #expire all procedures (they list hospitals)
    @procedures << Procedure.all.map{ |p| p.id }
    
    #expire all specialist that work in the hospital
    #we don't need to expire specializations of specialist in the hospital, since we expire all specializations
    hospital.offices_in.each do |o|
      @specialists << o.specialists.map{ |s| s.id }
    end
    
    #expire all clinics that are in the hospital
    #we don't need to expire specializations of clinics in the hospital, since we expire all specializations
    @clinics << hospital.clinics_in.map{ |c| c.id }
  end
end