class LatestUpdates
  class ProfileEvents < ServiceObject
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TagHelper

    attribute :profile
    attribute :division, Division

    def call
      if HIDE_IF.any?{|condition| condition.call(profile, division)}
        return []
      else
        self_events + locations_events
      end
    end

    HIDE_IF = [
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

    def self_events
      SELF_EVENT_TYPES.inject([]) do |memo, event|
        if event[:klass] == profile.class && event[:test].call(profile)
          memo << event[:event].call(profile, division)
        else
          memo
        end
      end
    end

    SELF_EVENT_TYPES = [
      {
        klass: Clinic,
        test: -> (clinic) { clinic.try(:closed?) },
        event: -> (clinic, division) {
          {
            item_id: clinic.id,
            item_type: clinic.class.to_s,
            event_code: LatestUpdatesMask::EVENTS.key(:closed),
            division_id: division.id,
            date: clinic.change_date(&:closed?),
            markup: begin
              clinic_link =
                link_to(clinic.name, "/clinics/#{clinic.id}")
              closed =
                "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has "\
                  "closed."

              "#{clinic_link} #{closed}".html_safe
            end
          }
        }
      },
      {
        klass: Specialist,
        test: -> (specialist) { specialist.try(:moved_away?) },
        event: -> (specialist, division) {
          {
            item_id: specialist.id,
            item_type: specialist.class.to_s,
            event_code: LatestUpdatesMask::EVENTS.key(:moved_away),
            division_id: division.id,
            date: specialist.change_date(&:moved_away?),
            markup: begin
              specialist_link =
                link_to(specialist.name, "/specialists/#{specialist.id}")
              moved_away =
                "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has "\
                  "moved away."

              "#{specialist_link} #{moved_away}".html_safe
            end
          }
        }
      },
      {
        klass: Specialist,
        test: -> (specialist) { specialist.try(:retired?) },
        event: -> (specialist, division) {
          {
            item_id: specialist.id,
            item_type: specialist.class.to_s,
            event_code: LatestUpdatesMask::EVENTS.key(:retired),
            division_id: division.id,
            date: (specialist.practice_end_date ||
              specialist.change_date(&:retired?)),
            markup: begin
              specialist_link =
                link_to(specialist.name, "/specialists/#{specialist.id}")
              retired =
                "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has "\
                  "retired."

              "#{specialist_link} #{retired}".html_safe
            end
          }
        }
      },
      {
        klass: Specialist,
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
            event_code: LatestUpdatesMask::EVENTS.key(:retiring),
            division_id: division.id,
            date: specialist.change_date(&:retiring?),
            markup: begin
              specialist_link =
                link_to(specialist.name, "/specialists/#{specialist.id}")
              is_retiring =
                "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) is "\
                  "retiring on #{specialist.practice_end_date.to_s(:long_ordinal)}"

              "#{specialist_link} #{is_retiring}".html_safe
            end
          }
        }
      }
    ]

    def locations_events
      locations =
        if profile.class == Clinic && profile.accepting_new_referrals?
          profile.clinic_locations
        elsif profile.class == Specialist && profile.accepting_new_direct_referrals?
          profile.specialist_offices
        else
          []
        end

      locations.inject([]) do |memo, location|
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
          event_code: LatestUpdatesMask::EVENTS.key(:opened_recently),
          division_id: division.id,
          date: date,
          markup: locations_event_markup(profile, events.map{|event| event[:record] })
        }
      end
    end

    def locations_event_markup(profile, locations)
      case profile
      when Specialist
        office_link =
          link_to(
            "#{profile.name}'s office",
            "/specialists/#{profile.id}"
          )
        opening_cities =
          locations.map(&:city).select(&:present?).map(&:name).uniq

        if opening_cities.any?
          recently_opened =
            "(#{profile.specializations.map{ |s| s.name }.to_sentence}) has"\
              " recently opened in #{opening_cities.to_sentence} and is "\
              "accepting new referrals."

          "#{office_link} #{recently_opened}".html_safe
        else
          recently_opened =
            "(#{profile.specializations.map{ |s| s.name }.to_sentence}) has"\
              " recently opened and is accepting new referrals."

          "#{office_link} #{recently_opened}".html_safe
        end
      when Clinic
        clinic_link = link_to(profile.name, "/clinics/#{profile.id}")
        opening_cities =
          locations.map(&:city).select(&:present?).map(&:name).uniq

        if opening_cities.any?
          recently_opened =
            "(#{profile.specializations.map{ |s| s.name }.to_sentence}) has "\
              "recently opened in #{opening_cities.to_sentence} and is "\
              "accepting new referrals."

          "#{clinic_link} #{recently_opened}".html_safe
        else
          recently_opened =
            "(#{profile.specializations.map{ |s| s.name }.to_sentence}) has "\
              "recently opened and is accepting new referrals."

          "#{clinic_link} #{recently_opened}".html_safe
        end
      end
    end
  end
end
