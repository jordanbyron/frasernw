class GenerateSpecializationPage
  class GlobalData
    include ServiceObject.exec_with_args(
      :specialization
    )

    def exec
      {
        labels: {
          filterGroups: {
            procedureSpecializations: "Areas of practice",
            city: "Expand Search Area",
            languages: "Languages",
            referrals: "Referrals",
            schedule: "Schedule",
            sex: "Sex"
          },
          city: city_labels,
          procedureSpecializations: procedure_specialization_labels,
          acceptsReferralsViaPhone: "Accepts referrals Via phone",
          patientsCanBook: "Patients can call to book after referral",
          respondsWithin: "Responded to within",
          respondsWithinOptions: responds_within_options,
          schedule: Schedule::DAY_HASH,
          languages: language_labels
        }
      }
    end

    private

    def language_labels
      Language.all.inject({}) do |memo, language|
        memo.merge(language.id => language.name)
      end.merge(0 => "Interpreter Available")
    end


    def city_labels
      City.all.inject({}) do |memo, city|
        memo.merge(city.id => city.name)
      end
    end

    def procedure_specialization_labels
      specialization.procedure_specializations.includes(:procedure).all.inject({}) do |memo, ps|
        memo.merge(ps.id => ps.procedure.try(:name))
      end
    end

    def responds_within_options
      Clinic::LAGTIME_HASH.merge(0 => "Any timeframe")
    end
  end
end
