class GenerateSpecializationPage
  class Clinics
    include ServiceObject.exec_with_args(
      :specialization,
      :referral_cities
    )
    include Referents

    def exec
      {
        contentClass: "DataTable",
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
            }
          },
          filterArrangements: {
            schedule: Schedule::DAY_HASH.keys,
            procedures: procedure_arrangement,
            respondsWithinOptions: lagtime_values_arrangement,
            languages: Language.order(:name).map(&:id),
            city: City.all.map(&:id)
          },
          filterFunction: "clinics",
          filterGroups: [
            "procedures",
            "referrals",
            "schedule",
            "languages",
            "city"
          ],
          tableHeadings: [
            { label: "Name", key: "NAME" },
            { label: "Accepting New Referrals?", key: "REFERRALS" },
            { label: "Average Non-urgent Patient Waittime", key: "WAITTIME" },
            { label: "City", key: "CITY" }
          ],
          rowGenerator: "referents",
          sortFunction: "referents",
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
      specialization.
        clinics.
        includes_location_data.
        includes(clinic_locations: {:schedule => [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]}).
        map do |clinic|
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
          languageIds: clinic.languages.map(&:id)
        }
      end
    end

    def schedule_filters
      Schedule::DAY_HASH.keys.inject({}) do |memo, day|
        memo.merge(day => false)
      end
    end
  end
end
