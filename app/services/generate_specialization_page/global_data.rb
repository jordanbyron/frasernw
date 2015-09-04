class GenerateSpecializationPage
  class GlobalData
    include ServiceObject.exec_with_args(
      :specialization
    )

    def exec
      {
        labels: {
          filterGroups: {
            procedures: "Areas of practice",
            city: "Expand Search Area",
            languages: "Languages",
            referrals: "Referrals",
            schedule: "Schedule",
            sex: "Sex",
            associations: "Associations",
            clinicDetails: "Clinic Details",
            careProviders: "Care Providers",
            subcategories: "Subcategories"
          },
          city: City.id_hash,
          hospitals: Hospital.id_hash,
          clinics: Clinic.id_hash,
          procedures: procedure_labels,
          careProviders: HealthcareProvider.id_hash,
          scCategories: ScCategory.id_hash,
          acceptsReferralsViaPhone: "Accepts referrals Via phone",
          patientsCanBook: "Patients can call to book after referral",
          respondsWithin: "Responded to within",
          respondsWithinOptions: responds_within_options,
          schedule: Schedule::DAY_HASH,
          languages: Language.id_hash.merge(0 => "Interpreter Available"),
          respondsWithinSummaryLabels: responds_within_summary_labels,
          specialties: Specialization.id_hash
        }
      }
    end

    private

    def procedure_labels
      specialization.procedure_specializations.includes(:procedure).all.inject({}) do |memo, ps|
        memo.merge(ps.procedure.id => ps.procedure.try(:name))
      end
    end

    def responds_within_options
      Clinic::LAGTIME_HASH.merge(0 => "Any timeframe")
    end

    def responds_within_summary_labels
      Clinic::LAGTIME_HASH.inject({}) do |memo, (key, value)|
        label = begin
          if key == 1
            "by phone when office calls for appointment"
          elsif key == 2
            "within one week"
          else
            "within #{value}"
          end
        end

        memo.merge({key => label})
      end
    end
  end
end
