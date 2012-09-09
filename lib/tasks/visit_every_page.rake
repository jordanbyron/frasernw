namespace :pathways do
  namespace :visit_every_page do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers
  
    task :specializations => :environment do
      puts "Recaching specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialization #{s.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :procedures => :environment do
      puts "Recaching procedures..."
      Procedure.all.sort{ |a,b| a.id <=> b.id }.each do |p|
        puts "Procedure #{p.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/areas_of_practice/#{p.id}/#{p.token}/refresh_cache") )
      end
    end
  
    task :specialists => :environment do
      puts "Recaching specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialist #{s.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :clinics => :environment do
      puts "Recaching clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Clinic #{c.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
    end
  
    task :hospitals => :environment do
      puts "Recaching hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Hospital #{h.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
    end
  
    task :languages => :environment do
      puts "Recaching languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Language #{l.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
      end
    end
  
    task :search => :environment do
      puts "Recaching search..."
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:languages, :hospitals, :procedures, :clinics, :specialists, :specializations, :search] do
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