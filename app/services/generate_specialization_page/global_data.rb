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
            associations: "Associations"
          },
          city: city_labels,
          hospitals: hospital_labels,
          clinics: clinic_labels,
          procedures: procedure_labels,
          acceptsReferralsViaPhone: "Accepts referrals Via phone",
          patientsCanBook: "Patients can call to book after referral",
          respondsWithin: "Responded to within",
          respondsWithinOptions: responds_within_options,
          schedule: Schedule::DAY_HASH,
          languages: language_labels,
          respondsWithinSummaryLabels: responds_within_summary_labels,
          specialties: specialization_labels
        }
      }
    end

    private

    def clinic_labels
      Clinic.all.inject({}) do |memo, clinic|
        memo.merge(clinic.id => clinic.name)
      end
    end

    def hospital_labels
      Hospital.all.inject({}) do |memo, hospital|
        memo.merge(hospital.id => hospital.name)
      end
    end


    def specialization_labels
      Specialization.all.inject({}) do |memo, specialization|
        memo.merge(specialization.id => specialization.name)
      end
    end

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


      LAGTIME_HASH = {
        1 => "Book by phone when office calls for referral",
        2 => "Within one week",
        3 => "1-2 weeks",
        4 => "2-4 weeks",
        5 => "1-2 months",
        6 => "2-4 months",
        7 => "4-6 months",
        8 => "6-9 months",
        9 => "9-12 months",
        10 => "12-18 months",
        11 => "18-24 months",
        12 => "2-2.5 years",
        13 => "2.5-3 years",
        14 => ">3 years"
      }
  end
end
