namespace :pathways do
  namespace :recache do
    include ActionController::Caching::Actions
    include ActionController::Caching::Fragments
    include Net
    include Rails.application.routes.url_helpers

    task :specializations => :environment do
      puts "Recaching specializations..."
      Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
        begin
          puts "Specialization #{s.id}"
          expire_fragment specialization_path(s)
          Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_cache") )

          City.all.sort{ |a,b| a.id <=> b.id }.each do |c|
            puts "Specialization City #{c.id}"
            expire_fragment "#{specialization_path(s)}_#{city_path(c)}"
            Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
          end

          Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
            puts "Specialization Division #{d.id}"
            expire_fragment "#{specialization_path(s)}_#{division_path(d)}"
            Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
          end

          #expire the grouped together cities
          User.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.uniq.each do |city_group|
            expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
          end

          #expire the grouped together divisions
          User.all_user_division_groups_cached.each do |division_group|
            expire_fragment "specialization_#{s.id}_content_divisions_#{division_group.join('_')}"
          end
        rescue Exception => e
          puts e.message
          puts "retrying.."
          retry
        end
      end
    end

    task :procedures => :environment do
      puts "Recaching procedures..."
      Procedure.all.sort{ |a,b| a.id <=> b.id }.each do |p|
        puts "Procedure #{p.id}"
        expire_fragment procedure_path(p)
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

    task :specialists_index => :environment do
      puts "Recaching Specialists Index..."
      Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
        Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
          # true / false represent can_edit? variable in view
          expire_fragment "specialists_index_#{s.id}_#{d.id}_#{false}"
          expire_fragment "specialists_index_#{s.id}_#{d.id}_#{true}"
        end
      end
      User.all_user_division_groups_cached.each do |division_group|

        puts "Specialist Index User Division #{division_group.join('_')}"
        expire_fragment("specialists_index_#{division_group.join('_')}_for_specializations_#{Specialization.all.sort{ |a,b| a.id <=> b.id }.map(&:id).join('_')}")

        Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
          puts "Specialist Index Specialization #{s.id} User Division #{division_group.join('_')}"
          expire_fragment("specialists_index_no_division_tab_#{s.id}")
          expire_fragment("specialists_index_#{division_group.join('_')}_for_specializations_#{s.id}")
        end
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

      puts "Global"
      expire_fragment "livesearch_global"
      Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_global.js") )

      puts "All entries"
      expire_fragment "livesearch_all_entries"
      Specialization.all.each do |s|
        puts "All entries specialization #{s.id}"
        expire_fragment "livesearch_all_entries_#{specialization_path(s)}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_all_entries/#{s.id}.js") )
      end

      Division.all.each do |d|
        puts "Search division #{d.id}"
        expire_fragment "livesearch_#{division_path(d)}_entries"
        Specialization.all.each do |s|
          puts "Search division #{d.id} specialization #{s.id}"
          expire_fragment "livesearch_#{division_path(d)}_#{specialization_path(s)}_entries"
          Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_division_entries/#{d.id}/#{s.id}.js") )
        end
        expire_fragment "livesearch_#{division_path(d)}_content"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/refresh_livesearch_division_content/#{d.id}.js") )
      end
    end

    task :sc_categories => :environment do
      puts "Recaching content categories..."
      User.all_user_division_groups_cached.each do |division_group|
        ScCategory.all.sort{ |a,b| a.id <=> b.id }.each do |cc|
          puts "Content Category #{cc.id}"
          expire_fragment "content_#{cc.id}_category_#{division_group.join('_')}"
        end
      end
    end

    task :menus => :environment do
      expire_fragment 'specialization_dropdown_admin'

      User.all_user_division_groups_cached.each do |division_group|
        expire_fragment "specialization_dropdown_#{division_group.join('_')}"

        Specialization.all.each do |specialization|
          expire_fragment "specialization_#{specialization.id}_nav_#{division_group.join('_')}"
        end
      end
    end

    task :front => :environment do
      User.all_user_division_groups_cached.each do |division_group|
        expire_fragment "latest_updates_#{division_group.join('_')}"
        expire_fragment "featured_content_#{division_group.join('_')}"
      end
    end

    task :application_layout => :environment do
      User.all_user_division_groups_cached.each do |division_group|
        expire_fragment("resources_dropdown_categories_#{division_group.join('_')}")
      end
    end

    #purposeful order from least important to most important, to keep cache 'hot'
    task :all => [:specialists_index, :procedures, :languages, :hospitals, :clinics, :specialists, :sc_categories, :specializations, :menus, :search, :front, :application_layout] do
      puts "All pages recached."
    end

    #utility expiration tasks

    task :specialization_pages => :environment do
      puts "Expiring specialization pages..."
      Specialization.all.each do |s|
        puts "Specialization #{s.name}"
        expire_fragment specialization_path(s)

        #expire the grouped together cities
        User.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.uniq.each do |city_group|
          expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
        end
      end

      #expire the grouped together divisions
      User.all_user_division_groups_cached.each do |division_group|
        puts "Divisions #{division_group.join(' ')}"
        Specialization.all.each do |s|
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

      City.all.sort{ |a,b| a.id <=> b.id }.each do |c|
        puts "Specialization City #{c.id}"
        expire_fragment "#{specialization_path(s)}_#{city_path(c)}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_city_cache/#{c.id}.js") )
      end

      Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
        puts "Specialization Division #{d.id}"
        expire_fragment "#{specialization_path(s)}_#{division_path(d)}"
        Net::HTTP.get( URI("http://#{APP_CONFIG[:domain]}/specialties/#{s.id}/#{s.token}/refresh_division_cache/#{d.id}.js") )
      end

      #expire the grouped together cities
      User.all.map{ |u| City.for_user_in_specialization(u, s).map{ |c| c.id } }.uniq.each do |city_group|
        expire_fragment "specialization_#{s.id}_content_cities_#{city_group.join('_')}"
      end

      #expire the grouped together divisions
      User.all_user_division_groups_cached.each do |division_group|
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