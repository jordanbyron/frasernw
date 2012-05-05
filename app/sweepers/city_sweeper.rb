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
    
    #expire all the clinics and specialists in the city, and their associated specializations, procedures, and languages (they list the city)
    city.addresses.each do |a|
      a.offices.each do |o|
        @specializations << o.specializations.map{ |s| s.id }
        @procedures << o.procedures.map{ |p| p.id }
        @specialists << o.specialists.map{ |s| s.id }
        @languages << o.languages.map{ |l| l.id }
      end
      (a.clinics + a.clinics_in_hospitals).each do |c|
        @specializations << c.specializations.map{ |s| s.id }
        @procedures << c.procedures.map{ |p| p.id }
        @clinics << c.id
        @languages << c.languages.map{ |l| l.id }
      end
      #expire hospitals in city
      @hospitals << a.hospitals.map{ |h| h.id }
    end
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end