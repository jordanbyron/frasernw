module Analytics
  module Frame
    class VisitorAccounts < Base
      def query
        @query ||= {
          metrics: [ :sessions ],
          dimensions: [ options[:dimensions], :user_id ].flatten,
        }.merge(options.slice(:start_date, :end_date))
      end

      def totaler
        Analytics::Totaler::Sum
      end

      def reducer
        Analytics::Reducer::User
      end
    end
  end
end
