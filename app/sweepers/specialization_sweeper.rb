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
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire specialization page
    expire_fragment :controller => 'specializations', :action => 'show'
    
    #expire all specialists pages that are in the specialties
    specialization.specialists.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
    
    #expire all procedures pages that are in the specialties
    specialization.procedures.each do |p|
      expire_fragment :controller => 'procedures', :action => 'show', :id => p.id
    end
    
    #expire all hospitals (they list specialties for specialists & clinics in the hospitals)
    Hospital.all.each do |h|
      expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id
    end
    
    #expire all languages (they list specialties for specialists & clinics speaking the language)
    Language.all.each do |l|
      expire_fragment :controller => 'languages', :action => 'show', :id => l.id
    end
  end
end