class HealthcareProviderSweeper < ActionController::Caching::Sweeper
  observe HealthcareProvider
  
  def after_create(healthcare_provider)
    expire_cache_for(healthcare_provider)
  end
  
  def after_update(healthcare_provider)
    expire_cache_for(healthcare_provider)
  end
  
  def after_destroy(healthcare_provider)
    expire_cache_for(healthcare_provider)
  end
  
  def expire_cache_for(healthcare_provider)
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue HealthcareProviderCacheRefreshJob.new(healthcare_provider.id)
  end
  
  class HealthcareProviderCacheRefreshJob < Struct.new(:healthcare_provider_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      healthcare_provider = HealthcareProvider.find(healthcare_provider_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all clinics that the healthcare_provider is in
      healthcare_provider.clinics.each do |c|
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      #expire all specialization pages, they list healthcare providers
      Specialization.all.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all procedures pages, they list healthcare providers
      Procedure.all.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
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