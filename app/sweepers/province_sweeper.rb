class ProvinceSweeper < ActionController::Caching::Sweeper
  observe Province
  
  def after_create(province)
    expire_cache_for(province)
  end
  
  def after_update(province)
    expire_cache_for(province)
  end
  
  def after_destroy(province)
    expire_cache_for(province)
  end
  
  def expire_cache_for(province)
    #expire sepcialists that work in the province in a delayed job
    Delayed::Job.enqueue ProvinceCacheRefreshJob.new(province.id)
  end
  
  class ProvinceCacheRefreshJob < Struct.new(:province_id)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      province = Province.find(province_id)
      
      #only specialists and clinic index cards list the province
      specialists = []
      clinics = []
      
      province.cities.each do |c|
        c.offices.each do |o|
          specialists << o.specialists
        end
        clinics << c.clinics + c.clinics_in_hospitals
      end
      
      #expire specialists in province
      specialists.flatten.uniq.each do |s|
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      #expire clinics in province
      clinics.flatten.uniq.each do
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