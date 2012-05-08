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
    #expire_action :controller => 'search', :action => 'livesearch', :format => :js
    expire_fragment :controller => 'specialists', :action => 'show'
  end
end