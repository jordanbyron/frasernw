namespace :pathways do
  namespace :recache do

    ROUTES = Rails.application.routes.url_helpers

    TASKS = {
      specialists: -> {
        Specialist.all.sort_by(&:id).each do |specialist|
          puts "Specialist #{specialist.id}"

          specialist.expire_cache
          HttpGetter.exec(
            "specialists/#{specialist.id}/#{specialist.token}/refresh_cache"
          )
        end
      },
      clinics: -> {
        Clinic.all.sort_by(&:id).each do |c|
          puts "Clinic #{c.id}"

          ExpireFragment.call ROUTES.clinic_path(c)
          HttpGetter.exec("clinics/#{c.id}/#{c.token}/refresh_cache")
        end
      },
      offices: -> {
        [
          :visible?,
          :presence
        ].each do |scope|
          Office.all_formatted_for_form(force: true, scope: scope)
        end
      },
      serialized_indices: -> {
        Denormalized.regenerate_all
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
    end
  end
end
