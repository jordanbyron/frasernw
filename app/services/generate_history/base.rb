class GenerateHistory
  class Base
    def self.for(target)
      self.new(target).exec
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
