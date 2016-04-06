namespace :pathways do
  namespace :recache do

    ROUTES = Rails.application.routes.url_helpers

    TASKS = {
      specialists: -> {
        Specialist.all.sort{ |a,b| a.id <=> b.id }.each do |specialist|
          puts "Specialist #{specialist.id}"

          specialist.cities(force: true)
          specialist.cities(force: true)

          ExpireFragment.call ROUTES.specialist_path(specialist)
          HttpGetter.exec("specialists/#{specialist.id}/#{specialist.token}/refresh_cache")
        end
      },
      serialized_indices: -> {
        Serialized.regenerate_all
      },
      specialists_index: -> {
        Division.all.sort{ |a,b| a.id <=> b.id }.each do |d|
          Specialization.all.sort{ |a,b| a.id <=> b.id }.each do |s|
            # true / false represent can_edit? variable in view
            puts "Specialists Index Specialization #{s.id} Division #{d.id}"
            ExpireFragment.call "specialists_index_#{s.cache_key}_#{s.specialists.cache_key}_#{d.cache_key}_#{true}"
            ExpireFragment.call "specialists_index_#{s.cache_key}_#{s.specialists.cache_key}_#{d.cache_key}_#{false}"
            ExpireFragment.call "specialists_index_no_division_tab_#{s.cache_key}_#{s.specialists.cache_key}"
            HttpGetter.exec("specialties/#{s.id}/#{s.token}/specialists/refresh_index_cache/#{d.id}")
          end
        end
      },
      languages: -> {
        Language.all.sort{ |a,b| a.id <=> b.id }.each do |l|
          puts "Language #{l.id}"
          ExpireFragment.call ROUTES.language_path(l)
          HttpGetter.exec("languages/#{l.id}/#{l.token}/refresh_cache")
        end
      },
      hospitals: -> {
        Hospital.all.sort{ |a,b| a.id <=> b.id }.each do |h|
          puts "Hospital #{h.id}"
          ExpireFragment.call ROUTES.hospital_path(h)
          HttpGetter.exec("hospitals/#{h.id}/#{h.token}/refresh_cache")
        end
      },
      clinics: -> {
        Clinic.all.sort{ |a,b| a.id <=> b.id }.each do |c|
          puts "Clinic #{c.id}"
          ExpireFragment.call ROUTES.clinic_path(c)
          HttpGetter.exec("clinics/#{c.id}/#{c.token}/refresh_cache")
        end
      },
      sc_categories: -> {
        User.all_user_division_groups_cached.each do |division_group|
          ScCategory.all.sort{ |a,b| a.id <=> b.id }.each do |cc|
            puts "Expiring Content Category #{cc.id} SuperAdmin"
            ExpireFragment.call "content_#{cc.id}_category_#{division_group.join('_')}_#{true}" #true/false represents @is_super_admin boolean
            puts "Expiring Content Category #{cc.id} User"
            ExpireFragment.call "content_#{cc.id}_category_#{division_group.join('_')}_#{false}"
          end
        end
      },
      menus: -> {
        ExpireFragment.call 'specialization_dropdown_admin'

        User.all_user_division_groups_cached.each do |division_group|
          ExpireFragment.call "specialization_dropdown_#{division_group.join('_')}"

          Specialization.all.each do |specialization|
            ExpireFragment.call "specialization_#{specialization.id}_nav_#{division_group.join('_')}"
          end
        end
      },
      search: -> {
        GlobalSearchData.new.regenerate_cache
        SearchDataLabels.new.regenerate_cache

        puts "All entries"
        ExpireFragment.call "livesearch_all_entries"
        Specialization.all.each do |s|
          puts "All entries specialization #{s.id}"
          ExpireFragment.call "livesearch_all_entries_#{ROUTES.specialization_path(s)}"
          HttpGetter.exec("refresh_livesearch_all_entries/#{s.id}.js")
        end

        Division.all.each do |division|
          puts "Search division #{division.id}"
          division.search_data.regenerate_cache
        end
      },
      front: -> {
        User.all_user_division_groups_cached.each do |division_group|
          ExpireFragment.call "featured_content_#{division_group.join('_')}"
          ExpireFragment.call "front_#{Specialization.cache_key}_#{division_group.join('_')}"
          Specialization.all.each do |specialization|
            ExpireFragment.call "front_#{specialization.cache_key}_#{division_group.join('_')}"
          end
        end
      },
      latest_updates: -> {
        LatestUpdates.recache_for_groups(
          User.all_user_division_groups_cached,
          force_automatic: true
        )
      },
      application_layout: -> {
        ExpireFragment.call("ie_compatibility_warning")
        User.all_user_division_groups_cached.each do |division_group|
          ExpireFragment.call("sc_category_global_navbar_#{division_group.join('_')}")
          ExpireFragment.call("resources_dropdown_categories_#{division_group.join('_')}")
        end
      },
      notifications: -> {
        PublicActivity::Activity.pluck(:id).each do |id|
          Rails.cache.delete("views/latest_notifications_for_#{id}")
        end
      },
      analytics_charts: -> {
        AnalyticsChart.regenerate_all
      }
    }

    TASKS.each do |name, body|
      task name => :environment do
        begin
          puts "Recaching #{name}..."

          body.call
        rescue => e
          SystemNotifier.error(e, annotation: "In #{name} task")
        end
      end
    end

    task :all => :environment do
      SystemNotifier.info("Beginning recache")

      TASKS.each do |name, body|
        begin
          puts "Recaching #{name}..."

          body.call
        rescue => e
          SystemNotifier.error(e, annotation: "In #{name} task")

          next
        end
      end

      puts "All pages recached."

      SystemNotifier.info("Recache successful")
    end
  end
end
