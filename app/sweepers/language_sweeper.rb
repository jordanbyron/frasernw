class LanguageSweeper < ActionController::Caching::Sweeper
  observe Language
  
  def after_create(language)
    init_lists
    add_to_lists(language)
    queue_job
  end
  
  def before_controller_update(language)
    init_lists
    expire_self
    add_to_lists(language)
  end
  
  def before_update(language)
    add_to_lists(language)
    queue_job
  end
  
  def before_controller_destroy(language)
    init_lists
    expire_self
    add_to_lists(language)
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
    expire_fragment :controller => 'languages', :action => 'show'
  end 
  
  def add_to_lists(language)
    
    #expire all specializations (they list all languages)
    @specializations << Specialization.all.map { |s| s.id }
    
    #expire all procedures (they list all languages)
    @procedures << Procedure.all.map{ |p| p.id }
    
    #expire all specialists that speak the language
    @specialists << language.specialists.map{ |s| s.id }
    
    #expire all clinics that speak the language
    @clinics << language.clinics.map{ |c| c.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end