class LatestUpdates
  include ServiceObject.exec_with_args(:max_automated_events, :divisions, :force)
  include ActionView::Helpers::UrlHelper

  def exec
    # puts "DIVISIONS: #{divisions.map(&:id)}"

    Rails.cache.fetch("latest_updates:#{max_automated_events}:#{divisions.map(&:id).sort.join("_")}", force: force) do
      manual_events = {}
      automated_events = {}

      NewsItem.specialist_clinic_in_divisions(divisions).each do |news_item|
        item = news_item.title.present? ? BlueCloth.new(news_item.title + ". " + news_item.body).to_html : BlueCloth.new(news_item.body).to_html

        manual_events["NewsItem_#{news_item.id}"] = ["#{news_item.start_date || news_item.end_date}", item.html_safe]
      end

      versions = Version.
        includes(:item).
        order("id desc").
        where("item_type in (?)", ["Specialist", "SpecialistOffice", "ClinicLocation"]).
        where("created_at > ?", (Date.today - 3.months))

      versions.each do |version|

        # for some reason stale cached versions of this are being served up below if we don't reload...
        item = version.item.try(:reload)

        next if item.blank?
        break if automated_events.length >= max_automated_events
        #
        # puts "Automated Events: #{automated_events}"
        # puts "# Automated Events: #{automated_events.length}"
        # puts "Offset Multipler: #{offset_multiplier}"
        # puts "Version Id: #{version.id}"

        begin

          if version.item_type == "Specialist"

            specialist = item
            specialist_cities = specialist.cities_for_front_page.flatten.uniq

            next if specialist.blank? || specialist.in_progress
            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if specialist specialization is not within local referral area of the division.
            next if (specialist_cities & divisions.map{|d| d.local_referral_cities(specialist.primary_specialization)}.flatten.uniq).blank?


            if version.event == "update"

              if specialist.moved_away?


                next if version.reify.blank?
                next if version.reify.moved_away? #moved away status hasn't changed
                next if (version.reify.unavailable_from < Date.today - 11.months)

                #newly moved away

                automated_events["#{version.item_type}_#{item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, "/specialists/#{specialist.id}", :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away.".html_safe]

              elsif specialist.retired?

                next if version.reify.blank?
                next if version.reify.retired? #retired status hasn't changed
                next if specialist.id == 242

                #newly retired

                automated_events["#{version.item_type}_#{item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, "/specialists/#{specialist.id}", :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired.".html_safe]

              elsif specialist.retiring?

                next if version.reify.blank?
                next if version.reify.retiring? #retiring status hasn't changed
                current_specialist = Specialist.find(specialist.id);

                automated_events["#{version.item_type}_#{item.id}"] = ["#{version.created_at}", "#{link_to specialist.name, "/specialists/#{specialist.id}", :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{current_specialist.unavailable_from.to_s(:long_ordinal)}.".html_safe]

              end

            end

          elsif version.item_type == "SpecialistOffice"
            specialist_office = item
            next if specialist_office.specialist.blank? || specialist_office.specialist.in_progress

            specialist = specialist_office.specialist

            specialist_cities = specialist.cities_for_front_page.flatten.uniq

            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if specialist specialization is not within local referral area of the division.
            next if (specialist_cities & divisions.map{|d| d.local_referral_cities(specialist.primary_specialization)}.flatten.uniq).blank?


            if (["create", "update"].include? version.event) && specialist.accepting_new_patients? && specialist_office.opened_recently?

              if (version.event == "update")
                  next if version.reify.blank?
                  next if version.reify.opened_recently? #opened this year status hasn't changed)
              end

              if specialist_office.city.present?
                automated_events["Specialist_#{specialist.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", "/specialists/#{specialist.id}", :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{specialist_office.city.name} and is accepting new referrals.".html_safe]
              else
                automated_events["Specialist_#{item.id}"] = ["#{version.created_at}", "#{link_to "#{specialist.name}'s office", "/specialists/#{specialist.id}", :class => 'ajax'} (#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals.".html_safe]
              end

            end

          elsif version.item_type == "ClinicLocation"

            next if version.changeset.keys == ["public", "private", "volunteer"]

            clinic_location = item
            next if clinic_location.clinic.blank? || clinic_location.clinic.in_progress #devnoteperformance: in_progress query creates 13 ActiveRecord Selects

            clinic = clinic_location.clinic

            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if clinic specialization is not within local referral area of the division.
            next if (clinic.cities & divisions.map{|d| d.local_referral_cities(clinic.primary_specialization)}.flatten.uniq).blank?

            if (["create", "update"].include? version.event) && clinic.accepting_new_patients? && clinic_location.opened_recently?

              if (version.event == "update")
                  next if version.reify.blank?
                  next if version.reify.opened_recently? #opened this year status hasn't changed)
              end

              if clinic_location.city.present?
                automated_events["Clinic_#{item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, "/clinics/#{clinic.id}", :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{clinic_location.city.name} and is accepting new referrals.".html_safe]
              else
                automated_events["Clinic_#{item.id}"] = ["#{version.created_at}", "#{link_to clinic.name, "/clinics/#{clinic.id}", :class => 'ajax'} (#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals.".html_safe]
              end

            end

          end
        rescue Exception => exc
          #automated_events['error_error'] = ["ding", exc]
        end
      end

      #mix in the news updates with the automatic updates
      automated_events.merge(manual_events).values.sort{ |a, b| b[0] <=> a[0] }.map{ |x| x[1] }
    end
  end
end
