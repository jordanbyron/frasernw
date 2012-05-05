class SpecializationSweeper < ActionController::Caching::Sweeper
  observe Specialization
  
  def after_create(specialization)
    init_lists
    add_to_lists(specialization)
    queue_job
  end
  
  def before_controller_update(specialization)
    init_lists
    expire_self
    add_to_lists(specialization)
  end
  
  def before_update(specialization)
    add_to_lists(specialization)
    queue_job
  end
  
  def before_controller_destroy(specialization)
    init_lists
    expire_self
    add_to_lists(specialization)
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
    expire_fragment :controller => 'specializations', :action => 'show'
  end 
  
  def add_to_lists(specialization)
    
    #expire all procedures that are in the specialization
    @procedures << specialization.procedures.map{ |p| p.id }
    
    #expire all specialists that are in the specialization
    @specialists << specialization.specialists.map{ |s| s.id }
    
    #expire all clinics that are in the specialization
    @clinics << specialization.clinics.map{ |c| c.id }
    
    #expire all hospitals the specialist has priviledges at
    @hospitals << Hospital.all.map{ |h| h.id }
    
    #expire all languages the specialist speaks
    @languages << Language.all.map{ |l| l.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end

end