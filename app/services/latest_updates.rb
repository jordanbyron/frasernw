class LatestUpdates < ServiceObject
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :only_current_manual_events, Axiom::Types::Boolean, default: true
  attribute :show_hidden, Axiom::Types::Boolean, default: false
  attribute :force_automatic, Axiom::Types::Boolean, default: false
  attribute :max_automatic_events, Integer, default: 100000
  attribute :division_ids, Array

  MAX_EVENTS = {
    front: 5,
    index: 100000
  }

  CURRENT_ONLY = {
    front: true,
    index: false
  }

  SHOW_HIDDEN = {
    front: false,
    index: true
  }

  def self.event_code(event)
    LatestUpdatesMask::EVENTS.key(event)
  end

  def self.recache_for_groups(division_id_groups, force_automatic: false)
    if force_automatic
      division_id_groups.flatten.uniq.each do |id|
        self.automatic(Division.find(id), force: true)
      end
    end

    division_id_groups.each do |group|
      self.recache_for(group)
    end
  end

  def self.recache_for(division_ids, force_automatic: false)
    MAX_EVENTS.each_with_index do |(context, max), index|
      call(
        max_automatic_events: max,
        only_current_manual_events: CURRENT_ONLY[context],
        division_ids: division_ids,
        force: true,
        force_automatic: force_automatic,
        show_hidden: SHOW_HIDDEN[context]
      )
    end
  end

  def self.for(context, divisions)
    call(
      max_automatic_events: MAX_EVENTS[context],
      only_current_manual_events: CURRENT_ONLY[context],
      division_ids: divisions.map(&:id),
      show_hidden: SHOW_HIDDEN[context]
    )
  end

  def self.automatic(division, force: false)
    Rails.cache.fetch(
      "latest_updates:automatic:division:#{division.id}",
      force: force
    ) do
        [Specialists, Clinics].inject([]) do |memo, klass|
          memo + klass.call(division: division)
        end
      end
  end

  def call
    Rails.cache.fetch(
      "latest_updates:#{division_ids.sort.join('_')}:"\
        "#{max_automatic_events}:#{show_hidden}",
      force: force
    ) do
      automatic_events = begin
        if show_hidden
          all_automatic_events
        else
          all_automatic_events.select{ |event| !event[:hidden] }
        end
      end.take(max_automatic_events)

      (manual_events + automatic_events).
        sort_by{ |event| [ event[:date].to_s, event[:markup] ] }.
        reverse
    end
  end

  def divisions
    @divisions ||= Division.find(division_ids)
  end

  def manual_events
    if only_current_manual_events
      NewsItem.current
    else
      NewsItem
    end.
      specialist_clinic_in_divisions(divisions).
      inject([]) do |memo, news_item|
        if news_item.title.present?
          memo << {
            markup: BlueCloth.
              new("#{news_item.title}. #{news_item.body}").
              to_html.html_safe,
            manual: true,
            hidden: false,
            date: (news_item.start_date || news_item.end_date)
          }
        else
          memo << {
            markup: BlueCloth.new(news_item.body).to_html.html_safe,
            manual: true,
            hidden: false,
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
          "(#{specialist.specializations.map{ |s| s.name }.to_sentence}) is retiring "\
            "on #{specialist.practice_end_date.to_s(:long_ordinal)}"

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
      }
    }
  }

  def all_automatic_events
    divisions.inject([]) do |memo, division|
      memo + LatestUpdates.automatic(division, force: force_automatic)
    end.map do |event|
      event.merge(hidden: LatestUpdatesMask.exists?(event.except(:markup)))
    end.group_by do |event|
      [ event[:item_type], event[:item_id], event[:event] ]
    end.map do |k, v|
        v[0].merge(hidden: v.any?{|event| event[:hidden] }, manual: false)
    end.
      sort_by{ |event| event[:date].to_s }.
      reverse
  end

  CONDITIONS_TO_HIDE_FROM_FEED = [
    -> (item, division) { item.blank? },
    -> (item, division) { !item.primary_specialization.present? },
    -> (item, division) { !item.primary_specialization_shown_in?([division]) },
    -> (item, division) {
      item_cities = item.cities.flatten.uniq
      local_referral_cities = division.
        local_referral_cities(item.primary_specialization)

      (item_cities & local_referral_cities).none?
    },
    -> (item, division) { item.hidden? }
  ]

  class Clinics < ServiceObject
    attribute :division, Division

    def call
      Clinic.
        includes_location_data.
        includes(:specializations).
        inject([]) do |memo, clinic|
          memo + ClinicEvents.call(clinic: clinic, division: division)
        end
    end

    class ClinicEvents < ServiceObject
      attribute :clinic, Clinic
      attribute :division, Division

      def call
        LatestUpdates::CONDITIONS_TO_HIDE_FROM_FEED.each do |condition|
          return [] if condition.call(clinic, division)
        end

        collapse(clinic_location_events)
      end

      def clinic_location_events
        return [] unless clinic.accepting_new_referrals?

        clinic.clinic_locations.inject([]) do |memo, clinic_location|
          if clinic_location.opened_recently?
            memo << {
              date: clinic_location.change_date(&:opened_recently?),
              record: clinic_location
            }
          else
            memo
          end
        end
      end

      def collapse(clinic_location_events)
        clinic_location_events.group_by do |event|
          event[:date]
        end.map do |date, events|
          {
            item_id: clinic.id,
            item_type: "Clinic",
            event_code: LatestUpdates.event_code(:opened_recently),
            division_id: division.id,
            date: date,
            markup: LatestUpdates::MARKUP["Clinic"][:opened_recently].call(
              clinic,
              events.map{|event| event[:record] }
            )
          }
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
        inject([]) do |memo, specialist|
          memo + SpecialistEvents.call(
            specialist: specialist,
            division: division
          )
        end
    end

    class SpecialistEvents < ServiceObject
      attribute :specialist, Specialist
      attribute :division, Division

      SPECIALIST_EVENTS = [
        {
          test: -> (specialist) { specialist.moved_away? },
          event: -> (specialist, division) {
            {
              item_id: specialist.id,
              item_type: "Specialist",
              event_code: LatestUpdates.event_code(:moved_away),
              division_id: division.id,
              date: specialist.change_date(&:moved_away?),
              markup: LatestUpdates::MARKUP["Specialist"][:moved_away].call(specialist)
            }
          }
        },
        {
          test: -> (specialist) { specialist.retired? },
          event: -> (specialist, division) {
            {
              item_id: specialist.id,
              item_type: "Specialist",
              event_code: LatestUpdates.event_code(:retired),
              division_id: division.id,
              date: (specialist.practice_end_date ||
                specialist.change_date(&:retired?)),
              markup: LatestUpdates::MARKUP["Specialist"][:retired].call(specialist)
            }
          }
        },
        {
          test: -> (specialist) {
            specialist.retiring? &&
              specialist.practice_end_date > Date.new(2016, 10, 18)
          },
          event: -> (specialist, division) {
            {
              item_id: specialist.id,
              item_type: "Specialist",
              event_code: LatestUpdates.event_code(:retiring),
              division_id: division.id,
              date: specialist.change_date(&:retiring?),
              markup: LatestUpdates::MARKUP["Specialist"][:retiring].call(specialist)
            }
          }
        }
      ]

      def call
        LatestUpdates::CONDITIONS_TO_HIDE_FROM_FEED.each do |condition|
          return [] if condition.call(specialist, division)
        end

        specialist_events + collapse(specialist_office_events)
      end

      def specialist_events
        SPECIALIST_EVENTS.inject([]) do |memo, event|
          if event[:test].call(specialist)
            memo << event[:event].call(specialist, division)
          else
            memo
          end
        end
      end

      def specialist_office_events
        return [] unless specialist.accepting_new_direct_referrals?

        specialist.specialist_offices.inject([]) do |memo, specialist_office|
          if specialist_office.opened_recently?
            memo << {
              record: specialist_office,
              date: specialist_office.change_date(&:opened_recently?)
            }
          else
            memo
          end
        end
      end

      def collapse(specialist_office_events)
        specialist_office_events.group_by do |event|
          event[:date]
        end.map do |date, events|
          {
            item_id: specialist.id,
            item_type: "Specialist",
            event_code: LatestUpdates.event_code(:opened_recently),
            division_id: division.id,
            date: date,
            markup: LatestUpdates::MARKUP["Specialist"][:opened_recently].call(
              specialist,
              events.map{ |event| event[:record] }
            )
          }
        end
      end
    end
  end
end
