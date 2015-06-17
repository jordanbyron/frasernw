namespace :pathways do
  namespace :visit_every_page do
    include Net
    include Rails.application.routes.url_helpers

    task :specializations => :environment do
      puts "Visiting specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        begin
          puts "Specialization #{s.id}"
          HttpGetter.exec("specialties/#{s.id}/#{s.token}/refresh_cache")

          City.all.sort{ |a,b| a.id <=> b.id }.each do |c|
            puts "Specialization City #{c.id}"
            HttpGetter.exec("specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js")
          end

          Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
            puts "Specialization Division #{d.id}"
            HttpGetter.exec("specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js")
          end
        end
      end
    end

    task :specialists => :environment do
      puts "Visiting specialists..."
      Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        puts "Specialist #{s.id}"
        HttpGetter.exec("specialists/#{s.id}/#{s.token}/refresh_cache")
      end
    end

    task :clinics => :environment do
      puts "Visiting clinics..."
      Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Clinic #{c.id}"
        HttpGetter.exec("clinics/#{c.id}/#{c.token}/refresh_cache" )
      end
    end

    task :hospitals => :environment do
      puts "Visiting hospitals..."
      Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
        puts "Hospital #{h.id}"
        HttpGetter.exec("hospitals/#{h.id}/#{h.token}/refresh_cache" )
      end
    end

    task :languages => :environment do
      puts "Visiting languages..."
      Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
        puts "Language #{l.id}"
        HttpGetter.exec("languages/#{l.id}/#{l.token}/refresh_cache" )
      end
    end

    task :search => :environment do
      puts "Visiting search..."

      puts "Global"
      HttpGetter.exec("refresh_livesearch_global.js" )

      puts "All entries"
      Specialization.all.each do |s|
        puts "All entries specialization #{s.id}"
        HttpGetter.exec("refresh_livesearch_all_entries/#{s.id}.js" )
      end

      Division.all.each do |d|
        puts "Search division #{d.id}"
        Specialization.all.each do |s|
          puts "Search division #{d.id} specialization #{s.id}"
          HttpGetter.exec("refresh_livesearch_division_entries/#{d.id}/#{s.id}.js" )
        end
        HttpGetter.exec("refresh_livesearch_division_content/#{d.id}.js" )
      end
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:languages, :hospitals, :clinics, :specialists, :specializations, :search] do
      puts "All pages visited."
    end
  end
end