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
    #expire clinic page
    expire_fragment :controller => 'clinics', :action => 'show'
    
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue ClinicCacheRefreshJob.new(clinic.id)
  end
  
  class ClinicCacheRefreshJob < Struct.new(:clinic_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      clinic = Clinic.find(clinic_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all specialization pages that the clinic is in
      clinic.specializations_including_in_progress.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all specialists pages that work in the clinic
      clinic.specialists_in.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all specialization pages of specialists that work in the clinic (they might have the clinics city on them)
      clinic.specializations_in.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all procedures pages that the clinic performs
      clinic.procedures.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all specialist pages the clinic has attending
      clinic.specialists.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all language pages the clinic speaks
      clinic.languages do |l|
        expire_fragment :controller => 'languages', :action => 'show', :id => l.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
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