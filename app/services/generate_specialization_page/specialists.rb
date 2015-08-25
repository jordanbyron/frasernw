class GenerateSpecializationPage
  class Specialists
    include ServiceObject.exec_with_args(
      :specialization,
      :referent_common_config
    )


    def exec
      {
        contentClass: "DataTable",
        props: {
          records: specialists,
          labels: {
            filterSection: "Filter Specialists"
          },
          filterFunction: "specialists",
          filterValues: referent_common_config[:filter_values].merge({
            schedule: {
              6 => false,
              7 => false
            }
          }),
          filterArrangements: {
            schedule: [6, 7]
          },
          filterComponents: [
            "procedureSpecializations",
            "referrals",
            "sex",
            "schedule",
            "languages",
            "city"
          ]
        }.merge(referent_common_config[:top_level])
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
          scheduledDayIds: specialist.day_ids
        }
      end
    end

  end
end
