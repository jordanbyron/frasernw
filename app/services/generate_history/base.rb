module GenerateHistory
  class Base
    attr_reader :target

    def initialize(target)
      @target = target
    end

    def exec
      raise NotImplementedError
    end
  end
end
