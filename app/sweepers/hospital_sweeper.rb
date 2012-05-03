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
    #expire hospital page
    expire_fragment :controller => 'hospitals', :action => 'show'
    
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue HospitalCacheRefreshJob.new(hospital.id)
  end
  
  class HospitalCacheRefreshJob < Struct.new(:hospital_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      hospital = Hospital.find(hospital_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all specialization pages (they list all hospitals)
      Specialization.all.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all procedures pages (they list all hospitals)
      Procedure.all.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all specialists that are associated with the hospital
      hospitals.specialists.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
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