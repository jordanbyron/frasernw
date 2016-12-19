class LatestUpdates
  class DivisionAutomaticEvents < ServiceObject
    attribute :division, Division
    attribute :force, Axiom::Types::Boolean, default: false

    def call
      Rails.cache.fetch(
        "latest_updates:automatic:division:#{division.id}",
        force: force
      ) do
          clinics_events + specialists_events
        end
    end

    def clinics_events
      Clinic.
        includes_location_data.
        includes(:specializations).
        inject([]) do |memo, clinic|
          memo + ProfileEvents.call(profile: clinic, division: division)
        end
    end

    def specialists_events
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
end
