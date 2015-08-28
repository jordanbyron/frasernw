class GenerateSpecializationPage
  class Specialists
    include ServiceObject.exec_with_args(
      :specialization,
      :referral_cities
    )
    include Referents

    def exec
      {
        contentClass: "DataTable",
        props: {
          records: specialists,
          labels: {
            filterSection: "Filter Specialists"
          },
          filterFunction: "specialists",
          filterValues: {
            procedureSpecializations: procedure_specialization_filters,
            city: city_filters,
            acceptsReferralsViaPhone: false,
            respondsWithin: 0,
            patientsCanBook: false,
            languages: language_filters,
            sex: {
              male: false,
              female: false
            },
            schedule: {
              6 => false,
              7 => false
            }
          },
          filterArrangements: {
            schedule: [6, 7],
            procedureSpecializations: procedure_specialization_arrangement,
            respondsWithinOptions: lagtime_values_arrangement,
            languages: Language.order(:name).map(&:id),
            city: City.order(:name).map(&:id)
          },
          filterGroups: [
            "procedureSpecializations",
            "referrals",
            "sex",
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
            procedureSpecializations: true,
            referrals: false,
            sex: false,
            schedule: false
          },
          collectionName: "specialists"
        }
      }
    end

    private


    def specialists
      specialization.specialists.map do |specialist|
        {
          id: specialist.id,
          name: specialist.name,
          statusIconClasses: specialist.status_class,
          waittime: specialist.waittime,
          cityIds: specialist.cities.map(&:id),
          collectionName: "specialists",
          procedureSpecializationIds: specialist.procedure_specializations.map(&:id),
          respondsWithin: specialist.lagtime_mask,
          acceptsReferralsViaPhone: specialist.referral_phone,
          patientsCanBook: specialist.patient_can_book?,
          sex: specialist.sex.downcase,
          scheduledDayIds: specialist.day_ids,
          languageIds: specialist.languages.map(&:id)
        }
      end
    end

  end
end
