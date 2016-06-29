class SeedCreator
  class HandledTable < self
    def self.model(klassname)
      Object.const_get(klassname)
    end
  end

  class SkippedTable < self
  end
end
