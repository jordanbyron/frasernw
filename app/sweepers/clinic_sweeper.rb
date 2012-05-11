class ClinicSweeper < ActionController::Caching::Sweeper
  observe Clinic
  
  def after_create(clinic)
    expire_cache_for(clinic)
  end
  
  def after_update(clinic)
    expire_cache_for(clinic)
  end
  
  def after_destroy(clinic)
    expire_cache_for(clinic)
  end
  
  def expire_cache_for(clinic)
    #expire_action :controller => 'search', :action => 'livesearch', :format => :js
    clinic.specialists.each do |s|
      #expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
  end
end