class HospitalSweeper < ActionController::Caching::Sweeper
  observe Hospital
  
  def after_create(hospital)
    expire_cache_for(hospital)
  end
  
  def after_update(hospital)
    expire_cache_for(hospital)
  end
  
  def after_destroy(hospital)
    expire_cache_for(hospital)
  end
  
  def expire_cache_for(hospital)
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire hospital page
    expire_fragment :controller => 'hospitals', :action => 'show'
    
    #expire all specialization pages (they list all hospitals)
    Specialization.all.each do |s|
      expire_fragment :controller => 'specializations', :action => 'show', :id => s.id
    end
    
    #expire all specialist pages that work in this hospital
    hospital.specialists.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
    
    #expire all procedures pages (they list all hospitals)
    Procedure.all.each do |p|
      expire_fragment :controller => 'procedures', :action => 'show', :id => p.id
    end
  end
end