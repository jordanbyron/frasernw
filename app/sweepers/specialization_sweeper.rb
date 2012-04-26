class SpecializationSweeper < ActionController::Caching::Sweeper
  observe Specialization
  
  def after_create(specialization)
    expire_cache_for(specialization)
  end
  
  def after_update(specialization)
    expire_cache_for(specialization)
  end
  
  def after_destroy(specialization)
    expire_cache_for(specialization)
  end
  
  def expire_cache_for(specialization)
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    specialization.specialists.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
  end
end