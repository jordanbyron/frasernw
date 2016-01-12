class NewLatestUpdates < ServiceObject
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :max_automated_events, Integer, default: 1000
  attribute :division_ids, Array

  def call
    (manual_events + automatic_events).
      sort_by{ |event| event[:date] }.
      map{ |event| event[:markup] }
  end

  def divisions
    @divisions ||= Division.find(division_ids)
  end

  def manual_events
    NewsItem.specialist_clinic_in_divisions(divisions).inject([]) do |memo, news_item|
      if news_item.title.present?
        memo << {
          markup: BlueCloth.new("#{news_item.title}. #{news_item.body}").to_html.html_safe,
          date: (news_item.start_date || news_item.end_date)
        }
      else
        memo << {
          markup: BlueCloth.new(news_item.body).to_html.html_safe,
          date: (news_item.start_date || news_item.end_date)
        }
      end
    end
  end

  extend ActionView::Helpers::UrlHelper
  extend ActionView::Helpers::TagHelper

  MARKUP = {
    "Specialist" => {
      moved_away: -> (specialist) {
        specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}")
        moved_away = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has moved away."

        "#{specialist_link} #{moved_away}".html_safe
      },
      retired: -> (specialist) {
        specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}")
        retired = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has retired."

        "#{specialist_link} #{retired}".html_safe
      },
      retiring: -> (specialist) {
        specialist_link = link_to(specialist.name, "/specialists/#{specialist.id}")
        is_retiring = "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring on #{specialist.unavailable_from.to_s(:long_ordinal)}"

        "#{specialist_link} #{is_retiring}".html_safe
      }
    },
    "SpecialistOffice" => {
      opened_recently: -> (specialist_office) {
        specialist = specialist_office.specialist
        office_link = link_to("#{specialist.name}'s office", "/specialists/#{specialist.id}")

        if specialist_office.city.present?
          recently_opened =
            "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{specialist_office.city.name} and is accepting new referrals."

          "#{office_link} #{recently_opened}".html_safe
        else
          recently_opened =
            "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals."

          "#{office_link} #{recently_opened}".html_safe
        end
      }
    },
    "ClinicLocation" => {
      opened_recently: -> (clinic_location) {
        clinic_link = link_to(clinic.name, "/clinics/#{clinic.id}")

        if clinic_location.city.present?
          recently_opened =
            "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened in #{clinic_location.city.name} and is accepting new referrals."

          "#{clinic_link} #{recently_opened}".html_safe
        else
          recently_opened =
            "(#{clinic.specializations.map{ |s| s.name }.to_sentence}) has recently opened and is accepting new referrals."

          "#{clinic_link} #{recently_opened}".html_safe
        end
      }
    }
  }

  def automatic_events
    raw_automatic_events.map do |event|
      {
        markup: MARKUP[event[:klass]][event[:event]].call(
          event[:klass].constantize.find(event[:id])
        ),
        date: event[:date]
      }
    end
  end

  def raw_automatic_events
    divisions.inject([]) do |memo, division|
      memo + Rails.cache.fetch("latest_updates:automatic:division:#{division.id}", force: force) do
        [
          Specialists,
          Clinics
        ].inject([]) do |memo, klass|
          memo + klass.call(division: division)
        end
      end
    end.
      uniq{ |event| [ event[:klass], event[:id], event[:event] ] }.
      sort_by{ |event| event[:date] }.
      reverse.
      take(max_automated_events)
  end

  CONDITIONS = [
    -> (item, division) { item.blank? },
    -> (item, division) { !item.primary_specialization.present? },
    -> (item, division) { !item.primary_specialization_complete_in?([division]) },
    -> (item, division) {
      item_cities = item.cities_for_front_page.flatten.uniq
      local_referral_cities = division.
        local_referral_cities(item.primary_specialization)

      (item_cities & local_referral_cities).none?
    }
  ]

  def self.event_date(item, event_method)
    item.versions.order(:created_at).find_last do |version|
      !version.reify.present? || !version.reify.send(event_method)
    end.created_at
  end

  class Clinics < ServiceObject
    attribute :division, Division

    def call
      Clinic.
        includes_location_data.
        all.
        inject([]) do |memo, clinic|
          memo + ClinicEvents.call(clinic: clinic, division: division)
        end
    end

    class ClinicEvents < ServiceObject
      attribute :clinic, Clinic
      attribute :division, Division

      def call
        NewLatestUpdates::CONDITIONS.each do |condition|
          return [] if condition.call(clinic, division)
        end

        clinic_location_events
      end

      def clinic_location_events
        return [] unless clinic.accepting_new_patients?

        clinic.clinic_locations.inject([]) do |memo, clinic_location|
          if clinic_location.opened_recently?
            memo << {
              id: clinic_location.id,
              klass: "SpecialistOffice",
              event: :opened_recently,
              date: NewLatestUpdates.event_date(clinic_location, :opened_recently?)
            }
          else
            memo
          end
        end
      end
    end
  end

  class Specialists < ServiceObject
    attribute :division, Division

    def call
      Specialist.
        includes_specialization_page.
        includes(:versions).
        includes(specialist_offices: :versions).
        all.
        inject([]) do |memo, specialist|

          memo + SpecialistEvents.call(specialist: specialist, division: division)
        end
    end

    class SpecialistEvents < ServiceObject
      attribute :specialist, Specialist
      attribute :division, Division

      SPECIALIST_EVENTS = [
        {
          test: -> (specialist) { specialist.moved_away? },
          event: -> (specialist) {
            {
              id: specialist.id,
              klass: "Specialist",
              event: :moved_away,
              date: NewLatestUpdates.event_date(specialist, :moved_away?)
            }
          }
        },
        {
          test: -> (specialist) { specialist.retired? },
          event: -> (specialist) {
            {
              id: specialist.id,
              klass: "Specialist",
              event: :retired,
              date: NewLatestUpdates.event_date(specialist, :retired?)
            }
          }
        },
        {
          test: -> (specialist) { specialist.retiring? },
          event: -> (specialist) {
            {
              id: specialist.id,
              klass: "Specialist",
              event: :retiring,
              date: NewLatestUpdates.event_date(specialist, :retiring?)
            }
          }
        }
      ]

      def call
        NewLatestUpdates::CONDITIONS.each do |condition|
          return [] if condition.call(specialist, division)
        end

        specialist_events + specialist_office_events
      end

      def specialist_events
        SPECIALIST_EVENTS.inject([]) do |memo, event|
          if event[:test].call(specialist)
            memo << event[:event].call(specialist)
          else
            memo
          end
        end
      end

      ## opened_recently --> opened?

      def specialist_office_events
        return [] unless specialist.accepting_new_patients?

        specialist.specialist_offices.inject([]) do |memo, specialist_office|
          if specialist_office.opened_recently?
            memo << {
              id: specialist_office.id,
              klass: "SpecialistOffice",
              event: :opened_recently,
              date: NewLatestUpdates.event_date(specialist_office, :opened_recently?)
            }
          else
            memo
          end
        end
      end
    end
  end
end
