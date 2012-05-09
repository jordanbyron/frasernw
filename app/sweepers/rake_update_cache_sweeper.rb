class RakeUpdateCacheSweeper < ActionController::Caching::Sweeper
  include ActionController::Caching::Actions
  include ActionController::Caching::Fragments
  include Net
  include Rails.application.routes.url_helpers # for url generation
  
  def rake_update_cache
    @controller ||= ActionController::Base
    expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
    Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
  end
  
  #so that we can call this from rake
  def self.rake_update_cache_extern
    new.rake_update_cache
  end
end