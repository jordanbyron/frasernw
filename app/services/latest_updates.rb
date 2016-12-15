class LatestUpdates < ServiceObject
  attribute :force, Axiom::Types::Boolean, default: false
  attribute :force_automatic, Axiom::Types::Boolean, default: false
  attribute :division_ids, Array
  attribute :context, Symbol

  def self.recache_for_groups(division_id_groups, force_automatic: false)
    # we only want to regenerate automatic events once per division, so we
    # do it separately, first
    if force_automatic
      division_id_groups.flatten.uniq.each do |id|
        self.division_automatic_events(Division.find(id), force: true)
      end
    end

    division_id_groups.each do |group|
      CONTEXTS.each do |context|
        call(
          context: context,
          division_ids: group,
          force: true,
          force_automatic: false
        )
      end
    end
  end

  def call
    Rails.cache.fetch(
      "latest_updates:#{division_ids.sort.join('_')}:#{context}",
      force: force
    ) do
      (manual_events + automatic_events).
        sort_by{ |event| [ event[:date].to_s, event[:markup] ] }.
        each_with_index.
        map{|event, index| event.merge(index: index)}.
        reverse.
        uniq
    end
  end

  private

  CONTEXTS = [
    :front,
    :index
  ]

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

  def automatic_events
    returning = divisions.inject([]) do |memo, division|
      memo + LatestUpdates.division_automatic_events(
        division,
        force: force_automatic
      )
    end.map do |event|
      event.merge(hidden: LatestUpdatesMask.exists?(event.except(:markup)))
    end.group_by do |event|
      [ event[:item_type], event[:item_id], event[:event] ]
    end.map do |k, v|
        v[0].merge(hidden: v.any?{|event| event[:hidden] }, manual: false)
    end.
      sort_by{ |event| event[:date].to_s }.
      reverse

    if !show_hidden
      returning = returning.select{ |event| !event[:hidden] }
    end

    returning.take(max_automatic_events)
  end

  def max_automatic_events
    case context
    when :front
      5
    when :index
      100000
    end
  end

  def only_current_manual_events
    context == :front
  end

  def show_hidden
    context == :index
  end

  def self.division_automatic_events(division, force: false)
    Rails.cache.fetch(
      "latest_updates:automatic:division:#{division.id}",
      force: force
    ) do
        Profiles.call(division: division)
      end
  end

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

  def self.event_code(event)
    LatestUpdatesMask::EVENTS.key(event)
  end

  class Profiles < ServiceObject
    attribute :division, Division

    def call
      [Specialists, Clinics].inject([]) do |memo, klass|
        memo + klass.call(division: division)
      end
    end

    class Clinics < ServiceObject
      attribute :division, Division
      def call
        Clinic.
          includes_location_data.
          includes(:specializations).
          inject([]) do |memo, clinic|
            memo + ProfileEvents.call(profile: clinic, division: division)
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
            memo + ProfileEvents.call(
              profile: specialist,
              division: division
            )
          end
      end
    end

    class ProfileEvents < ServiceObject
      attribute :profile
      attribute :division, Division

      PROFILE_EVENTS = [
        {
          test: -> (profile) { profile.try(:closed?) },
          event: -> (profile, division) {
            {
              item_id: profile.id,
              item_type: profile.class.to_s,
              event_code: LatestUpdates.event_code(:closed),
              division_id: division.id,
              date: profile.change_date(&:closed?),
              markup:
                LatestUpdates::MARKUP[profile.class.to_s][:closed].call(profile)
            }
          }
        },
        {
          test: -> (profile) { profile.try(:moved_away?) },
          event: -> (profile, division) {
            {
              item_id: profile.id,
              item_type: profile.class.to_s,
              event_code: LatestUpdates.event_code(:moved_away),
              division_id: division.id,
              date: profile.change_date(&:moved_away?),
              markup:
                LatestUpdates::MARKUP[profile.class.to_s][:moved_away].
                  call(profile)
            }
          }
        },
        {
          test: -> (profile) { profile.try(:retired?) },
          event: -> (profile, division) {
            {
              item_id: profile.id,
              item_type: profile.class.to_s,
              event_code: LatestUpdates.event_code(:retired),
              division_id: division.id,
              date: (profile.practice_end_date ||
                profile.change_date(&:retired?)),
              markup:
                LatestUpdates::MARKUP[profile.class.to_s][:retired].call(profile)
            }
          }
        },
        {
          test: -> (profile) {
            profile.try(:retiring?) &&
              profile.try(:practice_end_date) do
                profile.practice_end_date > Date.new(2016, 10, 18)
              end
          },
          event: -> (profile, division) {
            {
              item_id: profile.id,
              item_type: profile.class.to_s,
              event_code: LatestUpdates.event_code(:retiring),
              division_id: division.id,
              date: profile.change_date(&:retiring?),
              markup:
                LatestUpdates::MARKUP[profile.class.to_s][:retiring].call(profile)
            }
          }
        }
      ]

      def call
        LatestUpdates::CONDITIONS_TO_HIDE_FROM_FEED.each do |condition|
          return [] if condition.call(profile, division)
        end

        profile_events + location_events
      end

      def profile_events
        PROFILE_EVENTS.inject([]) do |memo, event|
          if event[:test].call(profile)
            memo << event[:event].call(profile, division)
          else
            memo
          end
        end
      end

      def location_events
        if (profile.class == Clinic) && profile.accepting_new_referrals?
          offices = profile.clinic_locations
        elsif (
          (profile.class == Specialist) &&
            profile.accepting_new_direct_referrals?
        )
          offices = profile.specialist_offices
        end

        return [] unless offices

        offices.inject([]) do |memo, office|
          if office.opened_recently?
            memo << {
              date: office.change_date(&:opened_recently?),
              record: office
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
    end
  end
end
