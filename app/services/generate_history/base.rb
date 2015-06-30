class GenerateHistory
  class Base
    def self.generator_for?(model_class)
      generator_for(model_class).present?
    end

    def self.generator_for(model_class)
      true
    end

    def self.exec(target)
      generator_for(target.class).new(target).exec
    end

    attr_reader :target

    def initialize(target)
      @target = target
    end

    def exec
      raise NotImplementedError
    end
  end
end
