class SpecialistSweeper < ActionController::Caching::Sweeper
  observe Specialist
  
  def after_create(specialist)
    expire_cache_for(specialist)
  end
  
  def after_update(specialist)
    expire_cache_for(specialist)
  end
  
  def after_destroy(specialist)
    expire_cache_for(specialist)
  end
  
  def expire_cache_for(specialist)
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire specialists page
    expire_fragment :controller => 'specialists', :action => 'show'
    
    #expire all specialization pages that the specialist is in
    specialist.specializations_including_in_progress.each do |s|
      expire_fragment :controller => 'specializations', :action => 'show', :id => s.id
    end
    
    #expire all procedures pages that the specialist performs
    specialist.procedures.each do |p|
      expire_fragment :controller => 'procedures', :action => 'show', :id => p.id
    end
    
    #expire all hospital pages the specialist attends
    specialist.hospitals.each do |h|
      expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id
    end
    
    #expire all language pages the specialist speaks
    specialist.languages do |l|
      expire_fragment :controller => 'languages', :action => 'show', :id => l.id
    end
  end
end