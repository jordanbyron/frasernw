class LatestUpdates < ServiceObject
  attribute :max_automated_events, Integer, default: 5
  attribute :division_ids, Array
  attribute :version_ids, Array, default: nil
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :force_automatic, Axiom::Types::Boolean, default: false
  attribute :whitelisted, Array, default: ["Specialist".freeze, "SpecialistOffice".freeze, "ClinicLocation".freeze]

  def call
    # puts "DIVISIONS: #{divisions.map(&:id)}"
    Rails.cache.fetch("latest_updates:#{max_automated_events}:#{division_ids.sort.join("_")}", force: force) do
      divisions = division_ids.map{ |id| Division.find(id) }
      #mix in the news updates with the automatic updates
      AutomatedEvents.call(
        max_automated_events: max_automated_events,
        divisions: divisions,
        force: force_automatic,
        version_ids: version_ids,
      ).merge(manual_events(divisions)).values.sort{ |a, b| b[0] <=> a[0] }.map{ |x| x[1] }
    end
  end

  def manual_events(divisions)
    manual_events = {}

    NewsItem.specialist_clinic_in_divisions(divisions).each do |news_item|
      item = news_item.title.present? ? BlueCloth.new(news_item.title + ". " + news_item.body).to_html : BlueCloth.new(news_item.body).to_html

      manual_events["NewsItem_#{news_item.id}"] = ["#{news_item.start_date || news_item.end_date}", item.html_safe]
    end

    manual_events
  end

  class AutomatedEvents < ServiceObject
    attribute :max_automated_events, Integer
    attribute :divisions, Array
    attribute :force, Boolean
    attribute :version_ids, Array
    attribute :whitelisted, Array, default: ["Specialist".freeze, "SpecialistOffice".freeze, "ClinicLocation".freeze]

    include ActionView::Helpers::UrlHelper

    def call
      Rails.cache.fetch("latest_automated_updates:#{max_automated_events}:#{divisions.map(&:id).sort.join("_")}", force: force) do
        generate
      end
    end

    def generate
      automated_events = {}

      if version_ids.present? # use below versions if passed in
        versions = Version.find(version_ids)
      else
        versions = Version.
          includes(:item).
          order("id desc").
          where("item_type in (?)", whitelisted).
          where("created_at > ?", (Date.current - 3.months))
      end
      versions.each do |version|

        next if !whitelisted.include?(version.item_type)

        # #reload so we make sure we're not picking up an old copy from a previous iteration
        item = version.item.try(:reload)

        next if item.blank? || item.id.blank?

        # we do this so when we call #reify on version it doesn't overwrite item back to old version
        item = version.item_type.camelize.constantize.find(item.id)

        break if automated_events.length >= max_automated_events

        begin

          if version.item_type == "Specialist"

            specialist = Specialist.with_cities.find(item.id)
            specialist_cities = specialist.cities_for_front_page.flatten.uniq

            next if specialist.blank? || specialist.in_progress

            next if !specialist.primary_specialization_complete_in?(divisions)
            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if specialist specialization is not within local referral area of the division.
            next if (specialist_cities & divisions.map{|d| d.local_referral_cities(specialist.primary_specialization)}.flatten.uniq).blank?

            if version.event == "update"

              if specialist.moved_away?


                next if version.reify.blank?
                next if version.reify.moved_away? #moved away status hasn't changed
                next if (version.reify.unavailable_from < Date.current - 11.months)

                #newly moved away

                specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}", :class => 'ajax')
                moved_away = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away."

                automated_events["#{version.item_type}_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{specialist_link} #{moved_away}".html_safe
                ]

              elsif specialist.retired?

                next if version.reify.blank?
                next if version.reify.retired? #retired status hasn't changed
                next if specialist.id == 242

                #newly retired

                specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}", :class => 'ajax')
                retired = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired."

                automated_events["#{version.item_type}_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{specialist_link} #{retired}".html_safe
                ]

              elsif specialist.retiring?

                next if version.reify.blank?
                next if version.reify.retiring? #retiring status hasn't changed
                current_specialist = Specialist.find(specialist.id);

                specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}")
                is_retiring = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{current_specialist.unavailable_from.to_s(:long_ordinal)}"

                automated_events["#{version.item_type}_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{specialist_link} #{is_retiring}".html_safe
                ]

              end

            end

          elsif version.item_type == "SpecialistOffice"
            specialist_office = item
            next if specialist_office.specialist.blank? || specialist_office.specialist.in_progress

            specialist = specialist_office.specialist

            specialist_cities = specialist.cities_for_front_page.flatten.uniq

            next if !specialist.primary_specialization_complete_in?(divisions)
            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if specialist specialization is not within local referral area of the division.
            next if (specialist_cities & divisions.map{|d| d.local_referral_cities(specialist.primary_specialization)}.flatten.uniq).blank?

            if (["create", "update"].include? version.event) && specialist.accepting_new_patients? && specialist_office.opened_recently?
              if (version.event == "update")
                next if version.reify.opened_recently? #opened this year status hasn't changed)
              end
              if specialist_office.city.present?

                office_link = link_to("#{specialist.name}'s office", "/specialists/#{specialist.id}", :class => 'ajax')
                recently_opened = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{specialist_office.city.name} and is accepting new referrals."

                automated_events["Specialist_#{specialist.id}"] = [
                  version.created_at.to_s,
                  "#{office_link} #{recently_opened}".html_safe
                ]
              else
                office_link = link_to("#{specialist.name}'s office", "/specialists/#{specialist.id}", :class => 'ajax')
                recently_opened = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals."

                automated_events["Specialist_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{office_link} #{recently_opened}".html_safe
                ]
              end

            end

          elsif version.item_type == "ClinicLocation"

            next if version.changeset.keys == ["public", "private", "volunteer"]

            clinic_location = item
            next if clinic_location.clinic.blank? || clinic_location.clinic.in_progress #devnoteperformance: in_progress query creates 13 ActiveRecord Selects

            clinic = clinic_location.clinic

            next if !clinic.primary_specialization_complete_in?(divisions)
            #Below: Division's define what cities they refer to for specific specializations.  Do not show version if clinic specialization is not within local referral area of the division.
            next if (clinic.cities & divisions.map{|d| d.local_referral_cities(clinic.primary_specialization)}.flatten.uniq).blank?

            if (["create", "update"].include? version.event) && clinic.accepting_new_patients? && clinic_location.opened_recently?

              if (version.event == "update")
                next if version.reify.opened_recently? #opened this year status hasn't changed)
              end

              if clinic_location.city.present?
                clinic_link = link_to(clinic.name, "/clinics/#{clinic.id}", :class => 'ajax')
                recently_opened = "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{clinic_location.city.name} and is accepting new referrals."

                automated_events["Clinic_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{clinic_link} #{recently_opened}".html_safe
                ]
              else
                clinic_link = link_to(clinic.name, "/clinics/#{clinic.id}", :class => 'ajax')
                recently_opened = "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals."

                automated_events["Clinic_#{item.id}"] = [
                  version.created_at.to_s,
                  "#{clinic_link} #{recently_opened}".html_safe
                ]
              end
            end

          end
        rescue Exception => exc
          #automated_events['error_error'] = ["ding", exc]
        end

      end
      automated_events
    end
  end
end
