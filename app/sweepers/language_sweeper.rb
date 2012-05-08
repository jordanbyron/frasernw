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
    #expire_action :controller => 'search', :action => 'livesearch', :format => :js
    language.specialists.each do |s|
      expire_fragment :controller => 'specialists', :action => 'show', :id => s.id
    end
  end
end