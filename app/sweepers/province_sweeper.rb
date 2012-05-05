class ProvinceSweeper < ActionController::Caching::Sweeper
  observe Province
  
  def after_create(province)
    init_lists
    add_to_lists(province)
    queue_job
  end
  
  def before_controller_update(province)
    init_lists
    expire_self
    add_to_lists(province)
  end
  
  def before_update(province)
    add_to_lists(province)
    queue_job
  end
  
  def before_controller_destroy(province)
    init_lists
    expire_self
    add_to_lists(province)
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
    expire_fragment :controller => 'provinces', :action => 'show'
  end 
  
  def add_to_lists(province)
    #only specialists and clinic index cards list the province
    province.addresses.each do |a|
      a.offices.each do |o|
        @specialists << o.specialists.map{ |s| s.id }
      end
      @clinics << (a.clinics + a.clinics_in_hospitals).map{ |c| c.id }
    end
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
end