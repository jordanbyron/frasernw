class HealthcareProviderSweeper < ActionController::Caching::Sweeper
  observe HealthcareProvider
  
  def after_create(healthcare_provider)
    init_lists
    add_to_lists(healthcare_provider)
    queue_job
  end
  
  def before_controller_update(healthcare_provider)
    init_lists
    expire_self
    add_to_lists(healthcare_provider)
  end
  
  def before_update(healthcare_provider)
    add_to_lists(healthcare_provider)
    queue_job
  end
  
  def before_controller_destroy(healthcare_provider)
    init_lists
    expire_self
    add_to_lists(healthcare_provider)
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
    expire_fragment :controller => 'healthcare_providers', :action => 'show'
  end 
  
  def add_to_lists(healthcare_provider)
    
    #expire all specializations, they list healthcare providers
    @specializations << Specialization.all.map { |s| s.id }
    
    #expire all procedures, they list healthcare providers
    @procedures << Procedure.all.map{ |p| p.id }
    
    #expire all clinics that the healthcare_provider is in
    @clinics << healthcare_provider.clinics.map{ |c| c.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end