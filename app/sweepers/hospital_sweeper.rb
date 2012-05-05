class HospitalSweeper < ActionController::Caching::Sweeper
  observe Hospital
  
  def after_create(hospital)
    init_lists
    add_to_lists(hospital)
    queue_job
  end
  
  def before_controller_update(hospital)
    init_lists
    expire_self
    add_to_lists(hospital)
  end
  
  def before_update(hospital)
    add_to_lists(hospital)
    queue_job
  end
  
  def before_controller_destroy(hospital)
    init_lists
    expire_self
    add_to_lists(hospital)
    queue_job
  end
  
  def init_lists
    @specializations = []
    @procedures = []
    @specialists = []
    @clinics = []
    @hospitals = []
    @languages = []
  end
  
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
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end