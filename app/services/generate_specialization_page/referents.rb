class GenerateSpecializationPage
  module Referents
    def procedure_filters
      specialization.
        procedure_specializations.
        focused.
        inject({}) do |memo, ps|
          memo.merge(ps.procedure.id => false)
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
      end
    end

    def procedure_arrangement
      transform_procedure_specializations = Proc.new do |hash|
        hash.map do |key, value|
          {
            id: key.procedure.id,
            children: transform_procedure_specializations.call(value)
          }
        end.sort_by{ |elem| elem[:label] }
      end

      transform_procedure_specializations.call(
        specialization.arranged_procedure_specializations(:focused)
      )
    end

    def city_arrangement
      City.order(:name).map(&:id)
    end

    def languages_arrangement
      Language.order(:name).map(&:id)
    end

    def lagtime_values_arrangement
      ([ 0 ] + Clinic::LAGTIME_HASH.keys).sort
    end
  end
end
