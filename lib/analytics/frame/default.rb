module Analytics
  # For a single time period (frame)
  module Frame
    class Default < Base
      def query
        {
          metrics: [ metric ],
          dimensions: options[:dimensions],
        }.merge(options.slice(:start_date, :end_date))
      end

      def totaler
        Analytics::Totaler::Analytics
      end

      def reducer
        Analytics::NullReducer
      end
    end
  end
end
