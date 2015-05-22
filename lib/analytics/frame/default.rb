module Analytics
  # For a single time period (frame)

  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions
  module Frame
    class Default < Base
      def exec
        raw_table = HashTable.new(by_division_and_user_type)

        totals = Analytics::Totaler::Sum.new(
          original_table: raw_table,
          dimensions: [:division_id, :users_type_key],
          metric: metric,
          start_date: options[:start_date],
          end_date: options[:end_date]
        )

        raw_table.add_rows(totals)
      end

      def by_division_and_user_type
        Analytics::ApiAdapter.get(construct_query([:division_id, :user_type_key]))
      end

      def base_query
        {
          metrics: [ metric ]
        }.merge(options.slice(:start_date, :end_date))
      end

      def construct_query(dimensions)
        if dimensions.present?
          base_query.merge(dimensions: dimensions)
        else
          base_query
        end
      end
    end
  end
end
