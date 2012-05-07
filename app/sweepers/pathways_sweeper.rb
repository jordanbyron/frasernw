class PathwaysSweeper < ActionController::Caching::Sweeper
  
  def after_create(entity)
    init_lists
    add_to_lists(entity)
    queue_job
  end
  
  def before_controller_update(entity)
    init_lists
    expire_self
    add_to_lists(entity)
  end
  
  def before_update(entity)
    add_to_lists(entity)
    queue_job
  end
  
  def before_controller_destroy(entity)
    init_lists
    expire_self
    add_to_lists(entity)
    queue_job
  end
  
  def init_lists
    @specializations = []
    @procedures = []
    @specialists = []
    @clinics = []
    @hospitals = []
    @languages = []
  end
  
  def queue_job
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
    
  class PathwaysCacheRefreshJob < Struct.new(:specialization_ids, :procedure_ids, :specialist_ids, :clinic_ids, :hospital_ids, :language_ids)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      
      puts "specialiations: #{@specializations}"
      puts "procedures: #{@procedures}"
      puts "specialists: #{@specialists}"
      puts "clinics: #{@clinics}"
      puts "hospitals: #{@hospitals}"
      puts "languages: #{@languages}"
      
      #expire search data
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      #Net::HTTP.get( URI("#{APP_CONFIG[:domain]}/livesearch.js") )
      
      specialization_ids.flatten.uniq.each.each do |s_id|
        s = Specialization.find(s_id)
        expire_fragment :controller => 'specializations', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      procedure_ids.flatten.uniq.each.each do |p_id|
        p = Procedure.find(p_id)
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      specialist_ids.flatten.uniq.each.each do |s_id|
        s = Specialist.find(s_id)
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      clinic_ids.flatten.uniq.each.each do |c_id|
        c = Clinic.find(c_id)
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      hospital_ids.flatten.uniq.each.each do |h_id|
        h = Hospital.find(h_id)
        expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
      
      language_ids.flatten.uniq.each.each do |l_id|
        l = Language.find(l_id)
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