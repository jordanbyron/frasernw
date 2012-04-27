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
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire clinics page
    expire_fragment :controller => 'clinics', :action => 'show'
    
    #expire all specialization pages that the clinics is in
    clinic.specializations_including_in_progress.each do |s|
      expire_fragment :controller => 'specializations', :action => 'show', :id => s.id
    end
    
    #expire all procedures pages that the clinic performs
    clinic.procedures.each do |p|
      expire_fragment :controller => 'procedures', :action => 'show', :id => p.id
    end
    
    #expire all language pages the clinic speaks
    clinic.languages do |l|
      expire_fragment :controller => 'languages', :action => 'show', :id => l.id
    end
  end
end