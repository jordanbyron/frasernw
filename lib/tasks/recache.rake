namespace :pathways do
  namespace :recache do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers
  
    task :specializations => :environment do
      puts "Recaching specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialization #{s.id}"
        expire_fragment specialization_path(s)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specializations/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :procedures => :environment do
      puts "Recaching procedures..."
      Procedure.all.sort{ |a,b| a.id <=> b.id }.each do |p|
        puts "Procedure #{p.id}"
        expire_fragment :controller => 'procedures', :action => 'show', :id => p.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/procedures/#{p.id}/#{p.token}/refresh_cache") )
      end
    end
  
    task :specialists => :environment do
      puts "Recaching specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialist #{s.id}"
        expire_fragment :controller => 'specialists', :action => 'show', :id => s.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :clinics => :environment do
      puts "Recaching clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Clinic #{c.id}"
        expire_fragment :controller => 'clinics', :action => 'show', :id => c.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
    end
  
    task :hospitals => :environment do
      puts "Recaching hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Hospital #{h.id}"
        expire_fragment :controller => 'hospitals', :action => 'show', :id => h.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
    end
  
    task :languages => :environment do
      puts "Recaching languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Language #{l.id}"
        expire_fragment :controller => 'languages', :action => 'show', :id => l.id, :host => APP_CONFIG[:domain]
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
      end
    end
  
    task :search => :environment do
      puts "Recaching search..."
      expire_action :controller => 'search', :action => 'livesearch', :format => :js, :host => APP_CONFIG[:domain]
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
    end

    task :all => [:specializations, :procedures, :specialists, :clinics, :hospitals, :languages, :search] do
      puts "All pages recached."
    end
    
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