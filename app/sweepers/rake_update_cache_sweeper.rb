class RakeUpdateCacheSweeper < ActionController::Caching::Sweeper
  include ActionController::Caching::Actions
  include ActionController::Caching::Fragments
  include Net
  include Rails.application.routes.url_helpers # for url generation
  
  def rake_update_cache
    @controller ||= ActionController::Base

    language_ids.flatten.uniq.each.each do |l_id|
      l = Language.find(l_id)
      puts "expiring language #{l.name}, #{l.id}"
      expire_fragment language_path(l)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
    end
    
    hospital_ids.flatten.uniq.each.each do |h_id|
      h = Hospital.find(h_id)
      puts "expiring hospital #{h.name}, #{h.id}"
      expire_fragment hospital_path(h)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
    end
    
    procedure_ids.flatten.uniq.each.each do |p_id|
      p = Procedure.find(p_id)
      puts "expiring procedure #{p.name}, #{p.id}"
      expire_fragment procedure_path(p)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/areas_of_practice/#{p.id}/#{p.token}/refresh_cache") )
    end
    
    clinic_ids.flatten.uniq.each.each do |c_id|
      c = Clinic.find(c_id)
      puts "expiring clinic #{c.name}, #{c.id}"
      expire_fragment clinic_path(c)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
    end
    
    specialist_ids.flatten.uniq.each.each do |s_id|
      s = Specialist.find(s_id)
      puts "expiring specialist #{s.name}, #{s.id}"
      expire_fragment specialist_path(s)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
    end
    
    specialization_ids.flatten.uniq.each.each do |s_id|
      s = Specialization.find(s_id)
      puts "expiring specialization #{s.name}, #{s.id}"
      expire_fragment specialization_path(s)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
    end
    
    expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
    Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
  end
  
  #so that we can call this from rake
  def self.rake_update_cache_extern
    new.rake_update_cache
  end
end