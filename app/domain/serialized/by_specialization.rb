module Serialized
  module BySpecialization
    def self.cache_key(generator_key, specialization)
      "serialized:by_specialization:#{specialization.id}:#{generator_key}"
    end

    def self.regenerate_all
      Specialization.all.each do |specialization|
        GENERATORS.keys.each{ |key| regenerate(key, specialization) }
      end
    end

    def self.fetch(generator_key, specialization)
      Rails.cache.fetch(cache_key(generator_key, specialization)) do
        self.generate(generator_key, specialization)
      end
    end

    def self.generate(generator_key, specialization)
      GENERATORS[generator_key].call(specialization)
    end

    def self.regenerate(generator_key, specialization)
      Rails.cache.write(
        cache_key(generator_key, specialization),
        self.generate(generator_key, specialization)
      )
    end

    GENERATORS = {
      nested_procedure_ids: Module.new do
        def self.call(specialization)
          transform_nested_procedure_specializations(
            specialization.procedure_specializations.includes(:procedure).arrange
          )
        end

        def self.transform_nested_procedure_specializations(procedure_specializations)
          procedure_specializations.inject({}) do |memo, (ps, children)|
            memo.merge({
              ps.procedure.id => {
                focused: ps.focused?,
                children: transform_nested_procedure_specializations(children)
              }
            })
          end
        end
      end
    }
  end
end
