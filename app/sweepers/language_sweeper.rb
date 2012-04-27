class LanguageSweeper < ActionController::Caching::Sweeper
  observe Language
  
  def after_create(language)
    expire_cache_for(language)
  end
  
  def after_update(language)
    expire_cache_for(language)
  end
  
  def after_destroy(language)
    expire_cache_for(language)
  end
  
  def expire_cache_for(language)
    #expire search data
    expire_action :controller => 'search', :action => 'livesearch', :format => :js
    
    #expire language page
    expire_fragment :controller => 'languages', :action => 'show'
    
    #expire all specialization pages (they list all languages)
    Specialization.all.each do |s|
      expire_fragment :controller => 'specializations', :action => 'show', :id => s.id
    end
    
    #expire all specialists that speak this language
    language.specialists.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
    
    #expire all procedures pages (they list all languages)
    Procedure.all.each do |p|
      expire_fragment :controller => 'procedures', :action => 'show', :id => p.id
    end
    
    #expire all hospitals (they list specialties for specialists & clinics in the hospitals)
    Hospital.all.each do |h|
      expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id
    end
  end
end