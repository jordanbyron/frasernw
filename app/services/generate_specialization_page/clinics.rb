class GenerateSpecializationPage
  class Clinics
    include ServiceObject.exec_with_args(
      :specialization,
      :referent_common_config
    )

    def exec
      {
        contentClass: "DataTable",
        props: {
          records: clinics,
          labels: {
            filterSection: "Filter Clinics"
          },
          filterValues: referent_common_config[:filter_values].merge({
            schedule: Schedule::DAY_HASH.keys.inject({}) do |memo, day|
              memo.merge(day => false)
            end
          }),
          filterArrangements: {
            schedule: Schedule::DAY_HASH.keys
          },
          filterFunction: "clinics",
          filterComponents: ["procedureSpecializations", "referrals", "schedule", "city"]
        }.merge(referent_common_config[:top_level])
      }
    end

    private

    def clinics
      specialization.
        clinics.
        includes(clinic_locations: {:schedule => [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday]}).
        map do |clinic|
        {
          id: clinic.id,
          name: clinic.name,
          statusIconClasses: clinic.status_class,
          waittime: clinic.waittime,
          cityIds: clinic.cities.map(&:id),
          collectionName: "clinics",
          procedureSpecializationIds: clinic.procedure_specializations.map(&:id),
          respondsWithin: clinic.lagtime_mask,
          acceptsReferralsViaPhone: clinic.referral_phone,
          patientsCanBook: clinic.patient_can_book?,
          scheduledDayIds: clinic.day_ids
        }
      end
    end

  end

end
