module Reporter
  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions
  module ByDivisionAndUserType
    class Base
      def self.time_series(metric, options)
        Month.for_interval(options[:start_month], options[:end_month]).inject(Table.new([])) do |table, month|
          month_table = period(
            metric,
            start_date: month.start_date,
            end_date: month.end_date
          )
          table.add_column(
            other_table: month_table,
            keys_to_match: [:division_id, :user_type_key],
            old_column_key: metric,
            new_column_key: month
          )
        end
      end

      def self.period(metric, options)
        Table.new(AnalyticsApiAdapter.get({
          metrics: [ metric ],
          dimensions: [:user_type_key, :division_id]
        }.merge(options.slice(:start_date, :end_date))))
      end
    end
  end
end
