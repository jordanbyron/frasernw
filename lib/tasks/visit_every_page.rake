namespace :pathways do
  namespace :visit_every_page do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers

    task :specializations => :environment do
      puts "Loading specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        begin
          puts "Requesting Specialization #{s.id}"
          Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
          
          City.all.sort{ |a,b| a.id <=> b.id }.each do |c|
            puts "Requesting Specialization #{s.id}: City #{c.id}"
            Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
          end
          
          Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
            puts "Requesting Specialization #{s.id}: Division #{d.id}"
            Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
          end
          
          # #expire the grouped together cities
          # User.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.uniq.each do |city_group|
          #   expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
          # end

          # #expire the grouped together divisions
          # User.all.map{ |u| u.divisions.map{ |d| d.id } }.uniq.each do |division_group|
          #   expire_fragment "specialization_#{s.id}_content_divisions_#{division_group.join('_')}"
          # end
        rescue Exception => e
          puts e.message
          puts "retrying.."
          retry
        end
      end
    end



  
    task :procedures => :environment do
      puts "Loading procedures..."
      Procedure.all.sort{ |a,b| a.id <=> b.id }.each do |p|
        puts "Requesting Procedure #{p.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/areas_of_practice/#{p.id}/#{p.token}/refresh_cache") )
      end
    end
  
    task :specialists => :environment do
      puts "Loading specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Requesting Specialist #{s.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
      end
    end
  
    task :clinics => :environment do
      puts "Loading clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Requesting Clinic #{c.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
      end
    end
  
    task :hospitals => :environment do
      puts "Loading hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Requesting Hospital #{h.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
      end
    end
  
    task :languages => :environment do
      puts "Loading languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Requesting Language #{l.id}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
      end
    end
  
    task :search => :environment do
      puts "Requesting / Loading livesearch.js..."
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/livesearch.js") )
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:languages, :hospitals, :procedures, :clinics, :specialists, :specializations, :search] do
      puts "All pages requested / visited / loaded for cache."
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