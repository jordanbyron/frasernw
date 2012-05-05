class SpecialistSweeper < ActionController::Caching::Sweeper
  observe Specialist
  
  def after_create(specialist)
    init_lists
    add_to_lists(specialist)
    queue_job
  end
  
  def before_controller_update(specialist)
    init_lists
    expire_self
    add_to_lists(specialist)
  end
  
  def before_update(specialist)
    add_to_lists(specialist)
    queue_job
  end
  
  def before_controller_destroy(specialist)
    init_lists
    expire_self
    add_to_lists(specialist)
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
    expire_fragment :controller => 'specialists', :action => 'show'
  end 
  
  def add_to_lists(specialist)
    
    #all specialization that the specialist is in
    @specializations << specialist.specializations_including_in_progress.map { |s| s.id }
    
    #expire all procedures that the specialist performs
    @procedures << specialist.procedures.map{ |p| p.id }
    
    #expire all specialist that the specialist works with
    specialist.offices.each do |o|
      o.specialists.each do |s|
        next if s.id == specialist.id
        @specialists << s.id
      end
    end
    
    #expire all clinics that the specialist attends
    @clinics << specialist.clinics.map{ |c| c.id }
    
    #expire all hospitals the specialist has priviledges at
    @hospitals << specialist.hospitals.map{ |h| h.id }
    
    #expire all languages the specialist speaks
    @languages << specialist.languages.map{ |l| l.id }
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
    
end