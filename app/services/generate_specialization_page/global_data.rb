class GenerateSpecializationPage
  class GlobalData
    include ServiceObject.exec_with_args(
      :specialization
    )

    def exec
      {
        labels: {
          filters: {
            procedureSpecializations: "Areas of practice",
            city: "Expand Search Area",
            languages: "Languages",
            referrals: "Referrals",
            schedule: "Schedule",
            sex: "Sex"
          },
          city: city_labels,
          procedureSpecializations: procedure_specialization_labels,
          referrals: {
            acceptsReferralsViaPhone: "Accepts referrals Via phone",
            patientsCanBook: "Patients can call to book after referral",
            respondsWithin: {
              self: "Responded to within",
              values: [{key: 0, label: "Any timeframe"}] + lagtimes
            },
          },
          sex: [
            { key: :male, label: "Male"},
            { key: :female, label: "Female"}
          ],
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

    def lagtimes
      Clinic::LAGTIME_HASH.map do |key, value|
        { key: key, label: value }
      end.sort_by{ |elem| elem[:key] }
    end

    def city_labels
      City.all.inject({}) do |memo, city|
        memo.merge(city.id => city.name)
      end
    end

    def procedure_specialization_labels
      transform_procedure_specializations = Proc.new do |hash|
        hash.map do |key, value|
          {
            key: key.id,
            label: key.procedure.name,
            children: transform_procedure_specializations.call(value)
          }
        end.sort_by{ |elem| elem[:label] }
      end

      transform_procedure_specializations.call(
        specialization.arranged_procedure_specializations(:focused)
      )
    end
  end
end
