module Analytics
  # For a single time period (frame)
  module Frame
    class Default < Base
      def query
        {
          metrics: [ options[:metric] ],
          dimensions: options[:dimensions],
        }.merge(options.slice(:start_date, :end_date))
      end

      def totaler
        Analytics::Totaler::Query
      end

      def reducer
        Analytics::Reducer::Null
      end
    end
  end
end
