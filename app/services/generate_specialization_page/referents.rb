class GenerateSpecializationPage
  class Referents
    include ServiceObject.exec_with_args(
      :specialization,
      :referral_cities
    )

    def exec
      {
        filter_values: filter_values,
        top_level: top_level
      }
    end

    def filter_values
      {
        procedureSpecializations: procedure_specialization_filters,
        city: city_filters,
        referrals: {
          acceptsReferralsViaPhone: false,
          respondsWithin: 0,
          patientsCanBook: false
        },
        languages: language_filters,
        sex: {
          male: false,
          female: false
        }
      }
    end

    def top_level
      {
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
        }
      }
    end

    def procedure_specialization_filters
      specialization.
        procedure_specializations.
        focused.
        inject({}) do |memo, ps|
          memo.merge(ps.id => false)
        end
    end

    def city_filters
      City.not_hidden.inject({}) do |memo, city|
        memo.merge(city.id => referral_cities.include?(city))
      end
    end

    def language_filters
      Language.all.inject({}) do |memo, language|
        memo.merge(language.id => false)
      end.merge(0 => false)
    end
  end
end
