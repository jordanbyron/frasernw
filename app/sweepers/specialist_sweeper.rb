class SpecialistSweeper < ActionController::Caching::Sweeper
  observe Specialist
  
  def after_create(specialist)
    expire_cache_for(specialist)
  end
  
  def after_update(specialist)
    expire_cache_for(specialist)
  end
  
  def after_destroy(specialist)
    expire_cache_for(specialist)
  end
  
  def expire_cache_for(specialist)
    #expire specialist page
    expire_fragment :controller => 'specialists', :action => 'show'
    
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue SpecialistCacheRefreshJob.new(specialist.id)
  end
  
  class SpecialistCacheRefreshJob < Struct.new(:specialist_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      specialist = Specialist.find(specialist_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all specialization pages that the specialist is in
      specialist.specializations_including_in_progress.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all procedures pages that the specialist performs
      specialist.procedures.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all hospital pages the specialist attends
      specialist.hospitals.each do |h|
        expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
      
      #expire all clinic pages the specialist attends
      specialist.clinics.each do |c|
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      #expire all language pages the specialist speaks
      specialist.languages do |l|
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