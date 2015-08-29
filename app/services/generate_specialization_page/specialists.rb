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
          records: hashified_specialists,
          labels: {
            filterSection: "Filter Specialists"
          },
          filterFunction: "specialists",
          filterValues: {
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
            schedule: {
              6 => false,
              7 => false
            },
            specializationId: specialization.id,
            specialization: false
          },
          filterArrangements: {
            schedule: [6, 7],
            procedures: procedure_arrangement,
            respondsWithinOptions: lagtime_values_arrangement,
            languages: Language.order(:name).map(&:id),
            city: City.order(:name).map(&:id)
          },
          filterGroups: [
            "procedures",
            "referrals",
            "sex",
            "schedule",
            "languages",
            "city"
          ],
          tableHeadings: [
            { label: "Name", key: "NAME" },
            { label: "Specialties", key: "SPECIALTIES" },
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
            procedures: true,
            referrals: false,
            sex: false,
            schedule: false
          },
          specializationFilter: true,
          collectionName: "specialists"
        }
      }
    end

    def hashified_specialists
      Rails.cache.fetch("serialized_specialists") do
        specialization.specialists.map do |specialist|
          {
            id: specialist.id,
            name: specialist.name,
            statusIconClasses: specialist.status_class,
            waittime: specialist.waittime,
            cityIds: specialist.cities.map(&:id),
            collectionName: "specialists",
            procedureIds: specialist.procedures.map(&:id),
            respondsWithin: specialist.lagtime_mask,
            acceptsReferralsViaPhone: specialist.referral_phone,
            patientsCanBook: specialist.patient_can_book?,
            sex: specialist.sex.downcase,
            scheduledDayIds: specialist.day_ids,
            languageIds: specialist.languages.map(&:id),
            specializationIds: specialist.specializations.map(&:id)
          }
        end
      end
    end

    private

    def specialists
      all
    end

    def all
      Specialist.includes_specialization_page.all
    end

    def in_this_specialization
      specialization.specialists.includes_specialization_page
    end

    def in_other_specializations
      Specialist.includes_specialization_page.performs_procedures_in(specialization)
    end

  end
end
