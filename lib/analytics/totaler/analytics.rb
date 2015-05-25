module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table

    class Analytics < Base
      def total_combination(combination)
        Analytics::ApiAdapter.get(construct_query([:user_type_key]))
      end

      def base_query
        {
          metrics: [ metric ]
        }.merge(options.slice(:start_date, :end_date))
      end

      def construct_query(dimensions)
        if dimensions.any?
          base_query.merge(dimensions: dimensions)
        else
          base_query
        end
      end
    end
  end
end