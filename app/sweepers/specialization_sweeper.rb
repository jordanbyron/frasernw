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
    #expire specialization page
    expire_fragment :controller => 'specializations', :action => 'show'
    
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue SpecializationCacheRefreshJob.new(specialization.id)
  end
  
  class SpecializationCacheRefreshJob < Struct.new(:specialization_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      specialization = Specialization.find(specialization_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => 'localhost:3000'
      #Net::HTTP.get( URI("#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all specialists pages that are in the specialty
      specialization.specialists.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all clinic pages that are in the specialty
      specialization.clinics.each do |c|
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      #expire all procedures pages that are in the specialty
      specialization.procedures.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all hospitals (they list specialties for specialists & clinics in the hospitals)
      Hospital.all.each do |h|
        expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
      
      #expire all languages (they list specialties for specialists & clinics speaking the language)
      Language.all.each do |l|
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