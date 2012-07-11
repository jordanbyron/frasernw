class PathwaysSweeper < ActionController::Caching::Sweeper
  
  def after_create(entity)
    init_lists
    add_to_lists(entity)
    queue_job
  end
  
  def before_controller_update(entity)
    init_lists
    expire_self(entity)
    add_to_lists(entity)
  end
  
  def before_update(entity)
    add_to_lists(entity)
    queue_job
  end
  
  def before_controller_destroy(entity)
    init_lists
    expire_self(entity)
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
    
    puts "specialiations: #{@specializations}"
    puts "procedures: #{@procedures}"
    puts "specialists: #{@specialists}"
    puts "clinics: #{@clinics}"
    puts "hospitals: #{@hospitals}"
    puts "languages: #{@languages}"
    
    Delayed::Job.enqueue PathwaysSweeper::PathwaysCacheRefreshJob.new(@specializations, @procedures, @specialists, @clinics, @hospitals, @languages)
  end
    
  class PathwaysCacheRefreshJob < Struct.new(:specialization_ids, :procedure_ids, :specialist_ids, :clinic_ids, :hospital_ids, :language_ids)
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers # for url generation
    
    def perform
      specialization_ids.flatten.uniq.each.each do |s_id|
        s = Specialization.find(s_id)
        puts "expiring specialization #{s.name}, #{s.id}"
        expire_fragment specialization_path(s)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      procedure_ids.flatten.uniq.each.each do |p_id|
        p = Procedure.find(p_id)
        puts "expiring procedure #{p.name}, #{p.id}"
        expire_fragment procedure_path(p)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/areas_of_practice/#{p.id}/#{p.token}/refresh_cache") )
      end
      
      specialist_ids.flatten.uniq.each.each do |s_id|
        s = Specialist.find(s_id)
        puts "expiring specialist #{s.name}, #{s.id}"
        expire_fragment specialist_path(s)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
      
      clinic_ids.flatten.uniq.each.each do |c_id|
        c = Clinic.find(c_id)
        puts "expiring clinic #{c.name}, #{c.id}"
        expire_fragment clinic_path(c)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
      
      hospital_ids.flatten.uniq.each.each do |h_id|
        h = Hospital.find(h_id)
        puts "expiring hospital #{h.name}, #{h.id}"
        expire_fragment hospital_path(h)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
      
      language_ids.flatten.uniq.each.each do |l_id|
        l = Language.find(l_id)
        puts "expiring language #{l.name}, #{l.id}"
        expire_fragment language_path(l)
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