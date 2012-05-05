class CitySweeper < ActionController::Caching::Sweeper
  observe City
  
  def after_create(city)
    init_lists
    add_to_lists(city)
    queue_job
  end
  
  def before_controller_update(city)
    init_lists
    expire_self
    add_to_lists(city)
  end
  
  def before_update(city)
    add_to_lists(city)
    queue_job
  end
  
  def before_controller_destroy(city)
    init_lists
    expire_self
    add_to_lists(city)
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
    expire_fragment :controller => 'cities', :action => 'show'
  end 
  
  def add_to_lists(city)
    
    #expire all the specialists in city, and specializations, procedures, and languages of specialists in the city (they list the city)
    city.addresses.each do |a|
      a.offices.each do |o|
        @specializations << o.specializations
        @procedures << o.procedures
        @specialists << o.specialists
        @languages << o.languages
      end
    end
    
    #expire clinics in city
    @clinics << (city.clinics + city.clinics_in_hospitals).map{ |c| c.id }
    
    #expire hospitals in city
    @hospitals << city.hospitals.map{ |h| h.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end