module Analytics
  # For a single time period (frame)

  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions
  module Frame
    class Default < Base
      def exec
        HashTable.new(by_division_and_user_type).
          add_rows(by_division).
          add_rows(by_user_type).
          add_rows(total)
      end

      def by_division_and_user_type
        Analytics::ApiAdapter.get(construct_query([:division_id, :user_type_key]))
      end

      def by_division
        Analytics::ApiAdapter.get(construct_query([:division_id]))
      end

      def by_user_type
        Analytics::ApiAdapter.get(construct_query([:user_type_key]))
      end

      def total
        Analytics::ApiAdapter.get(construct_query(nil))
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
