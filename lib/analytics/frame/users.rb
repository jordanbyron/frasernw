module Analytics
  module Frame
    class Users < Base
      def query
        {
          metrics: [ :sessions ],
          dimensions: (options[:dimensions] << :user_id),
        }.merge(options.slice(:start_date, :end_date))
      end

      def totaler
        Analytics::Totaler::Sum
      end

      def reducer
        Analytics::UserReducer
      end
    end
  end
end
