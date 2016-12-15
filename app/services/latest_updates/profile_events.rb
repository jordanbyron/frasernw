class LatestUpdates
  class ProfileEvents < ServiceObject
    attribute :profile
    attribute :division, Division

    def call
      CONDITIONS_TO_HIDE_FROM_FEED.each do |condition|
        return [] if condition.call(profile, division)
      end

      self_events + location_events
    end

    def self_events
      PROFILE_EVENT_TYPES[profile.class.name].inject([]) do |memo, event|
        if event[:test].call(profile)
          memo << event[:event].call(profile, division)
        else
          memo
        end
      end
    end

    def location_events
      locations =
        if profile.class == Clinic && profile.accepting_new_referrals?
          profile.clinic_locations
        elsif profile.class == Specialist && profile.accepting_new_direct_referrals?
          profile.specialist_offices
        else
          []
        end

      locations.inject([]) do |memo, office|
        if location.opened_recently?
          memo << {
            date: location.change_date(&:opened_recently?),
            record: location
          }
        else
          memo
        end
      end.group_by do |event|
        event[:date]
      end.map do |date, events|
        {
          item_id: profile.id,
          item_type: profile.class.to_s,
          event_code: LatestUpdates.event_code(:opened_recently),
          division_id: division.id,
          date: date,
          markup:
            LatestUpdates::MARKUP[profile.class.to_s][:opened_recently].call(
              profile,
              events.map{|event| event[:record] }
            )
        }
      end
    end

    def self_events
      case profile
      when Clinic
        
    end

    PROFILE_EVENT_TYPES = {
      "Clinic" => [
        {
          test: -> (clinic) { clinic.closed? },
          event: -> (clinic, division) {
            {
              item_id: clinic.id,
              item_type: clinic.class.to_s,
              event_code: LatestUpdates.event_code(:closed),
              division_id: division.id,
              date: clinic.change_date(&:closed?),
              markup:
                LatestUpdates::MARKUP[clinic.class.to_s][:closed].call(clinic)
            }
          }
        },
        {
          test: -> (clinic) { clinic.try(:moved_away?) },
          event: -> (clinic, division) {
            {
              item_id: clinic.id,
              item_type: clinic.class.to_s,
              event_code: LatestUpdates.event_code(:moved_away),
              division_id: division.id,
              date: clinic.change_date(&:moved_away?),
              markup:
                LatestUpdates::MARKUP[clinic.class.to_s][:moved_away].
                  call(clinic)
            }
          }
        }
      ],
      "Specialist" => [
        {
          test: -> (specialist) { specialist.try(:retired?) },
          event: -> (specialist, division) {
            {
              item_id: specialist.id,
              item_type: specialist.class.to_s,
              event_code: LatestUpdates.event_code(:retired),
              division_id: division.id,
              date: (specialist.practice_end_date ||
                specialist.change_date(&:retired?)),
              markup:
                LatestUpdates::MARKUP[specialist.class.to_s][:retired].call(specialist)
            }
          }
        },
        {
          test: -> (specialist) {
            specialist.try(:retiring?) &&
              specialist.try(:practice_end_date) do
                specialist.practice_end_date > Date.new(2016, 10, 18)
              end
          },
          event: -> (specialist, division) {
            {
              item_id: specialist.id,
              item_type: specialist.class.to_s,
              event_code: LatestUpdates.event_code(:retiring),
              division_id: division.id,
              date: specialist.change_date(&:retiring?),
              markup:
                LatestUpdates::MARKUP[specialist.class.to_s][:retiring].call(specialist)
            }
          }
        }
      ]
    }

    CONDITIONS_TO_HIDE_FROM_FEED = [
      -> (item, division) { item.blank? },
      -> (item, division) { item.specializations.none? },
      -> (item, division) { (item.specializations & division.showing_specializations).none? },
      -> (item, division) {
        item_cities = item.cities.flatten.uniq
        local_referral_cities = (item.specializations & division.showing_specializations).
          map{ |specialization| division.local_referral_cities(specialization) }.
          flatten.
          uniq

        (item_cities & local_referral_cities).none?
      },
      -> (item, division) { item.hidden? }
    ]

    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TagHelper

    MARKUP = {
      "Specialist" => {
        moved_away: -> (specialist) {
          specialist_link =
            link_to(specialist.name, "/specialists/#{specialist.id}")
          moved_away =
            "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has "\
              "moved away."

          "#{specialist_link} #{moved_away}".html_safe
        },
        retired: -> (specialist) {
          specialist_link =
            link_to(specialist.name, "/specialists/#{specialist.id}")
          retired =
            "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has "\
              "retired."

          "#{specialist_link} #{retired}".html_safe
        },
        retiring: -> (specialist) {
          specialist_link =
            link_to(specialist.name, "/specialists/#{specialist.id}")
          is_retiring =
            "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) is "\
              "retiring on #{specialist.practice_end_date.to_s(:long_ordinal)}"

          "#{specialist_link} #{is_retiring}".html_safe
        },
        opened_recently: -> (specialist, specialist_offices) {
          office_link =
            link_to(
              "#{specialist.name}'s office",
              "/specialists/#{specialist.id}"
            )
          opening_cities =
            specialist_offices.map(&:city).select(&:present?).map(&:name).uniq

          if opening_cities.any?
            recently_opened =
              "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has"\
                " recently opened in #{opening_cities.to_sentence} and is "\
                "accepting new referrals."

            "#{office_link} #{recently_opened}".html_safe
          else
            recently_opened =
              "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has"\
                " recently opened and is accepting new referrals."

            "#{office_link} #{recently_opened}".html_safe
          end
        }
      },
      "Clinic" => {
        opened_recently: -> (clinic, clinic_locations) {
          clinic_link = link_to(clinic.name, "/clinics/#{clinic.id}")
          opening_cities =
            clinic_locations.map(&:city).select(&:present?).map(&:name).uniq

          if opening_cities.any?
            recently_opened =
              "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has "\
                "recently opened in #{opening_cities.to_sentence} and is "\
                "accepting new referrals."

            "#{clinic_link} #{recently_opened}".html_safe
          else
            recently_opened =
              "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has "\
                "recently opened and is accepting new referrals."

            "#{clinic_link} #{recently_opened}".html_safe
          end
        },
        closed: -> (clinic) {
          clinic_link =
            link_to(clinic.name, "/clinics/#{clinic.id}")
          closed =
            "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has "\
              "closed."

          "#{clinic_link} #{closed}".html_safe
        }
      }
    }
  end
end
