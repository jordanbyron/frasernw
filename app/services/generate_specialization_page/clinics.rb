class GenerateSpecializationPage
  class Clinics
    include ServiceObject.exec_with_args(
      :specialization,
      :referral_cities
    )
    include Referents

    def exec
      {
        contentClass: "SpecializationClinicsPanel",
        props: {
          records: clinics,
          labels: {
            filterSection: "Filter Clinics"
          },
          filterValues: {
            schedule: schedule_filters,
            procedures: procedure_filters,
            city: city_filters,
            acceptsReferralsViaPhone: false,
            respondsWithin: 0,
            patientsCanBook: false,
            languages: language_filters,
            sex: {
              male: false,
              female: false
            },
            specializationId: specialization.id,
            specialization: false
          },
          filterArrangements: {
            schedule: Schedule::DAY_HASH.keys,
            procedures: procedure_arrangement,
            respondsWithinOptions: lagtime_values_arrangement,
            languages: Language.order(:name).map(&:id),
            city: City.all.map(&:id)
          },
          tableHeadings: [
            { label: "Name", key: "NAME" },
            { label: "Specialties", key: "SPECIALTIES" },
            { label: "Accepting New Referrals?", key: "REFERRALS" },
            { label: "Average Non-urgent Patient Waittime", key: "WAITTIME" },
            { label: "City", key: "CITY" }
          ],
          sortConfig: {
            column: "NAME",
            order: "ASC"
          },
          filterVisibility: {
            city: false,
            languages: false,
            procedures: false,
            referrals: false,
            schedule: false
          },
          collectionName: "clinics"
        }
      }
    end

    private

    def clinics
      Rails.cache.fetch("serialized_clinics") do
        all.map do |clinic|
          {
            id: clinic.id,
            name: clinic.name,
            statusIconClasses: clinic.status_class,
            waittime: clinic.waittime,
            cityIds: clinic.cities.map(&:id),
            collectionName: "clinics",
            procedureIds: clinic.procedures.map(&:id),
            respondsWithin: clinic.lagtime_mask,
            acceptsReferralsViaPhone: clinic.referral_phone,
            patientsCanBook: clinic.patient_can_book?,
            scheduledDayIds: clinic.scheduled_day_ids,
            languageIds: clinic.languages.map(&:id),
            specializationIds: clinic.specializations.map(&:id)
          }
        end
      end
    end

    def all
      Clinic.
        includes([:procedures, :specializations, :languages]).
        includes_location_data.
        includes_location_schedules.
        all
    end

    def in_this_specialization
      specialization.
        clinics.
        includes([:procedures, :specializations, :languages]).
        includes_location_data.
        includes_location_schedules
    end

    def in_other_specializations
      Clinic.
        performs_procedures_in(specialization).
        includes_location_data.
        includes_location_schedules
    end

    def schedule_filters
      Schedule::DAY_HASH.keys.inject({}) do |memo, day|
        memo.merge(day => false)
      end
    end
  end
end
