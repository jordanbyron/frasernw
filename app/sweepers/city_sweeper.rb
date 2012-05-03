class CitySweeper < ActionController::Caching::Sweeper
  observe City
  
  def after_create(city)
    expire_cache_for(city)
  end
  
  def after_update(city)
    expire_cache_for(city)
  end
  
  def after_destroy(city)
    expire_cache_for(city)
  end
  
  def expire_cache_for(city)
    #expire sepcialists that work in the city in a delayed job
    Delayed::Job.enqueue CityCacheRefreshJob.new(city.id)
  end
  
  class CityCacheRefreshJob < Struct.new(:city_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      city = City.find(city_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      specialists = []
      specializations = []
      procedures = []
      languages = []
      
      city.offices.each do |o|
        specialists << o.specialists
        specializations << o.specializations
        procedures << o.procedures
        languages << o.languages
      end
      
      #expire the specialist pages
      specialists.flatten.uniq.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all specialization pages of the specialists (they list cities)
      specializations.flatten.uniq.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all procedure pages of the specialists (they list cities)
      procedures.flatten.uniq.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all languages pages of the specialists (they list cities)
      languages.flatten.uniq.each do |l|
        expire_fragment :controller => 'languages', :action => 'show', :id => l.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
      end
      
      #expire clinics in city
      (city.clinics + city.clinics_in_hospitals).each do
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      #expire hospitals in city
      city.hospitals.each do
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
    end
    
    private
    
    # The following methods are defined to fake out the ActionController
    # requirements of the Rails cache
    
    def cache_store
      ActionController::Base.cache_store
    end
    
    def self.benchmark( *params )
      yield
    end
    
    def cache_configured?
      true
    end
    
  end
end