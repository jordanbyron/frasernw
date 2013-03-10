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
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
        
        City.all.each do |c|
          puts "Specialization City #{c.id}"
          expire_fragment "#{specialization_path(s)}_#{city_path(c)}"
          Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
        end
        
        Division.all.each do |d|
          puts "Specialization Division #{d.id}"
          expire_fragment "#{specialization_path(s)}_#{division_path(d)}"
          Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
        end
        
        //expire the grouped together cities
        Users.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.unique.each do |city_group|
          expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
        end
        
        //expire the grouped together divisions
        Users.all.map{ |u| u.divisions.map{ |d| d.id } }.unique.each do |division_group|
          expire_fragment "specialization_#{s.id}_content_divisions_#{division_group.join('_')}"
        end
      end
    end
  
    task :specialists => :environment do
      puts "Recaching specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialist #{s.id}"
        expire_fragment specialist_path(s)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :clinics => :environment do
      puts "Recaching clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Clinic #{c.id}"
        expire_fragment clinic_path(c)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
    end
  
    task :hospitals => :environment do
      puts "Recaching hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Hospital #{h.id}"
        expire_fragment hospital_path(h)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
    end
  
    task :languages => :environment do
      puts "Recaching languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Language #{l.id}"
        expire_fragment language_path(l)
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
      end
    end
  
    task :search => :environment do
      puts "Recaching search..."
      expire_fragment "livesearch_global"
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_global.js") )
      expire_fragment "livesearch_all_entries"
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_all_entries.js") )
      Division.all.each do |d|
        puts "Search division #{d.id}"
        expire_fragment "livesearch_#{division_path(d)}_entries"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_division_entries/#{d.id}.js") )
        expire_fragment "livesearch_#{division_path(d)}_content"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_division_content/#{d.id}.js") )
      end
    end
    
    task :front => :environment do
      expire_fragment 'latest_updates'
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:languages, :hospitals, :clinics, :specialists, :specializations, :search, :front] do
      puts "All pages recached."
    end
  
    #utility expiration tasks

    task :specialization_pages => :environment do
      puts "Expiring specialization pages..."
      Specialization.all.each do |s|
        expire_fragment specialization_path(s)
        
        //expire the grouped together cities
        Users.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.unique.each do |city_group|
          expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
        end
        
        //expire the grouped together divisions
        Users.all.map{ |u| u.divisions.map{ |d| d.id } }.unique.each do |division_group|
          expire_fragment "specialization_#{s.id}_content_divisions_#{division_group.join('_')}"
        end
      end
    end
    
    task :specialization_content => :environment do
      puts "Expiring specialization content..."
      Specialization.all.each do |s|
        City.all.each do |c|
          expire_fragment "#{specialization_path(s)}_#{city_path(c)}"
        end
        Division.all.each do |d|
          expire_fragment "#{specialization_path(s)}_#{division_path(d)}"
        end
      end
    end
    
    task :specific_specialization, [:specialization_id] => [:environment] do |t, args|
      specialization_id = args[:specialization_id] || -1
      if specialization_id == -1
        puts "Specify a specialization id with :specific_specialization[specialization_id]"
        return
      end
      s = Specialization.find(Integer(specialization_id))
      puts "Specialization #{s.id}"
      expire_fragment specialization_path(s)
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
      
      City.all.each do |c|
        puts "Specialization City #{c.id}"
        expire_fragment "#{specialization_path(s)}_#{city_path(c)}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
      end
      
      Division.all.each do |d|
        puts "Specialization Division #{d.id}"
        expire_fragment "#{specialization_path(s)}_#{division_path(d)}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
      end
        
      //expire the grouped together cities
      Users.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.unique.each do |city_group|
        expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
      end
      
      //expire the grouped together divisions
      Users.all.map{ |u| u.divisions.map{ |d| d.id } }.unique.each do |division_group|
        expire_fragment "specialization_#{s.id}_content_divisions_#{division_group.join('_')}"
      end
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