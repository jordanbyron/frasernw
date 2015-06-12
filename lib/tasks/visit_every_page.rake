namespace :pathways do
  namespace :visit_every_page do
    include Net
    include Rails.application.routes.url_helpers

    task :specializations => :environment do
      puts "Visiting specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        begin
          puts "Specialization #{s.id}"

            ["http", "https"].each do |http_format|
              Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )
            end

          City.all.sort{ |a,b| a.id <=> b.id }.each do |c|
            puts "Specialization City #{c.id}"
            ["http", "https"].each do |http_format|
              Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
            end
          end

          Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
            puts "Specialization Division #{d.id}"
            ["http", "https"].each do |http_format|
              Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
            end
          end
        end
      end
    end

    task :specialists => :environment do
      puts "Visiting specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialist #{s.id}"
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/specialists/#{s.id}/#{s.token}/refresh_cache") )
        end
      end
    end

    task :clinics => :environment do
      puts "Visiting clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Clinic #{c.id}"
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/clinics/#{c.id}/#{c.token}/refresh_cache") )
        end
      end
    end

    task :hospitals => :environment do
      puts "Visiting hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Hospital #{h.id}"
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/hospitals/#{h.id}/#{h.token}/refresh_cache") )
        end
      end
    end

    task :languages => :environment do
      puts "Visiting languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Language #{l.id}"
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/languages/#{l.id}/#{l.token}/refresh_cache") )
        end
      end
    end

    task :search => :environment do
      puts "Visiting search..."

      puts "Global"
      ["http", "https"].each do |http_format|
        Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/refresh_livesearch_global.js") )
      end

      puts "All entries"
      Specialization.all.each do |s|
        puts "All entries specialization #{s.id}"
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/refresh_livesearch_all_entries/#{s.id}.js") )
        end
      end

      Division.all.each do |d|
        puts "Search division #{d.id}"
        Specialization.all.each do |s|
          puts "Search division #{d.id} specialization #{s.id}"
          ["http", "https"].each do |http_format|
            Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/refresh_livesearch_division_entries/#{d.id}/#{s.id}.js") )
          end
        end
        ["http", "https"].each do |http_format|
          Net::HTTP.get( URI("#{http_format}://#{APP_CONFIG[:domain]}/refresh_livesearch_division_content/#{d.id}.js") )
        end
      end
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:languages, :hospitals, :clinics, :specialists, :specializations, :search] do
      puts "All pages visited."
    end
  end
end