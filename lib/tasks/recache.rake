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
        viewable_division_combinations.each do |division_group|
          ExpireFragment.call "featured_content_#{division_group.join('_')}"
        end
      },
      latest_updates: -> {
        LatestUpdates.recache_for_groups(
          ViewableDivisionCombinations.call,
          force_automatic: true
        )
      },
      application_layout: -> {
        ExpireFragment.call("ie_compatibility_warning")
        ViewableDivisionCombinations.call.each do |division_group|
          ExpireFragment.call(
            "resources_dropdown_categories_#{division_group.join('_')}"
          )
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

    task all: :environment do
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

    def viewable_division_combinations
      (User.all_user_division_groups_cached + Division.ids.map{ |id| [id ] }).
        uniq
    end

  end
end
