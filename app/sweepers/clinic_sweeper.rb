class ClinicSweeper < ActionController::Caching::Sweeper
  observe Clinic
  
  def after_create(clinic)
    init_lists
    add_to_lists(clinic)
    queue_job
  end
  
  def before_controller_update(clinic)
    init_lists
    expire_self
    add_to_lists(clinic)
  end
  
  def before_update(clinic)
    add_to_lists(clinic)
    queue_job
  end
  
  def before_controller_destroy(clinic)
    init_lists
    expire_self
    add_to_lists(clinic)
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
    expire_fragment :controller => 'clinics', :action => 'show'
  end 
  
  def add_to_lists(clinic)
    
    #all specialization that the clinic is in
    @specializations << clinic.specializations_including_in_progress.map { |s| s.id }
    #all specialization pages of specialists that work in the clinic (they might have the clinics city on them)
    @specializations << clinic.specializations_in.map{ |s| s.id }
    
    #expire all procedures that the clinic performs
    @procedures << clinic.procedures.map{ |p| p.id }
    #all procedure pages of specialists that work in the clinic (they might have the clinics city on them)
    @procedures << clinic.procedures_in.map{ |p| p.id }
    
    #expire all specialists attend the clinic
    @specialists << clinic.specialists.map{ |s| s.id }
    #expire all specialists that have offices in this clinic
    @specialists << clinic.specialists_in.map{ |s| s.id }
    
    #expire any hospital the clinic is in
    @hospitals << clinic.location.hospital_in.id if clinic.location.present? && clinic.location.hospital_in.present?
    
    #expire all languages the clinics speaks
    @languages << clinic.languages.map{ |l| l.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end