class ProcedureSweeper < ActionController::Caching::Sweeper
  observe Procedure
  
  def after_create(procedure)
    expire_cache_for(procedure)
  end
  
  def after_update(procedure)
    expire_cache_for(procedure)
  end
  
  def after_destroy(procedure)
    expire_cache_for(procedure)
  end
  
  def expire_cache_for(procedure)
    #expire procedure page
    expire_fragment :controller => 'procedures', :action => 'show'
    
    #expire all the related pages in a delayed job
    Delayed::Job.enqueue ProcedureCacheRefreshJob.new(procedure.id)
  end
  
  class ProcedureCacheRefreshJob < Struct.new(:procedure_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      procedure = Procedure.find(procedure_id)
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
      
      #expire all child procedure pages
      procedure.children.each do |p|
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      #expire all specialization pages that the procedure is in
      procedure.specializations_including_in_progress.each do |s|
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all specialists that perform this procedure or any child procedure
      procedure.all_specialists.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire all clinics that perform this procedure or any child procedure
      procedure.all_clinics.each do |c|
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