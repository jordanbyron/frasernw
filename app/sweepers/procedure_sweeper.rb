class ProcedureSweeper < ActionController::Caching::Sweeper
  observe Procedure
  
  def after_create(procedure)
    init_lists
    add_to_lists(procedure)
    queue_job
  end
  
  def before_controller_update(procedure)
    init_lists
    expire_self
    add_to_lists(procedure)
  end
  
  def before_update(procedure)
    add_to_lists(procedure)
    queue_job
  end
  
  def before_controller_destroy(procedure)
    init_lists
    expire_self
    add_to_lists(procedure)
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
    expire_fragment :controller => 'procedures', :action => 'show'
  end 
  
  def add_to_lists(procedure)
    
    #expire all specializations that the procedure is in
    @specializations << procedure.specializations_including_in_progress.map { |s| s.id }
    
    #expire all child procedures of this procedure
    @procedures << procedure.children.map{ |p| p.id }
    
    #expire all specialists that perform this or any child procedure
    @specialists << procedure.all_specialists.map{ |p| p.id }
    
    #expire all clinics that the specialist attends
    @clinics << procedure.all_clinics.map{ |c| c.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
  
end