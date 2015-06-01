module Analytics
  module Frame
    def self.exec(options)
      Analytics::Frame::Default.new(
        query_for(options),
        reducer_for(options),
        totaler_for(options),
      ).exec
    end

    def self.reducer_for(options)
      Analytics::Reducer.for(options)
    end

    def self.query_for(options)
      Analytics::Query.for(options)
    end

    def self.totaler_for(options)
      Analytics::Totaler.for(options)
    end
  end
end
