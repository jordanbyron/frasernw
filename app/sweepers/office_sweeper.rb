class OfficeSweeper < ActionController::Caching::Sweeper
  observe Office
  
  def after_create(office)
    init_lists
    add_to_lists(office)
    queue_job
  end
  
  def before_controller_update(office)
    init_lists
    expire_self
    add_to_lists(office)
  end
  
  def before_update(office)
    add_to_lists(office)
    queue_job
  end
  
  def before_controller_destroy(office)
    init_lists
    expire_self
    add_to_lists(office)
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
    expire_fragment :controller => 'offices', :action => 'show'
  end 
  
  def add_to_lists(office)
    
    #expire all specializations of specialists in the office (they list the city)
    @specializations << office.specializations.map { |s| s.id }
    
    #expire all procedures of specialists in the office (they list the city)
    @procedures << office.procedures.map{ |p| p.id }
    
    #expire all specialists in the office
    @specialists << office.specialists.map{ |s| s.id }
    
    #expire all hospital pages of the specialists (they list the city)
    @hospitals << office.hospitals.map{ |h| h.id }
    
    #expire all language pages of the specialists (they list the city)
    @languages << office.languages.map{ |l| l.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end