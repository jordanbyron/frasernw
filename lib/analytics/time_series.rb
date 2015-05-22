module Analytics
  module TimeSeries
    def self.exec(metric, options)
      Base.new(metric, options).exec
    end

    def self.by_path(asdf)
    end
  end
end
