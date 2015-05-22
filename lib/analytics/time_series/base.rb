module Analytics
  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions

  module TimeSeries
    class Base
      # TODO get actual start month
      START_MONTH = Month.new(2014, 1)

      # returns metric by division and user type
      attr_reader :metric, :options

      def initialize(metric, options)
        @metric = metric
        @options = options
      end

      def exec
        Analytics::AbstractTable.new(
          Rails.cache.fetch(cache_key, force: options[:force]) { generate }
        )
      end

      def generate
        months.inject(Table.new([])) do |memo, month|
          accumulate_to_table(memo, month)
        end.rows
      end

      def months
        @months = Month.for_interval(START_MONTH, end_month)
      end

      def end_month
        Month.prev
      end

      def cache_key
        "abstract_analytics_table:base:#{metric.to_s}:#{Month.current.to_cache_key}"
      end

      def accumulate_to_table(memo, month)
        month_table = frame_class.new(
          metric,
          start_date: month.start_date,
          end_date: month.end_date
        ).exec

        memo.add_column(
          other_table: month_table,
          keys_to_match: [:division_id, :user_type_key],
          old_column_key: metric,
          new_column_key: month
        )
      end

      def frame_class
        if [:users, :users_min_5_sessions, :users_min_10_sessions].include? metric
          Analytics::Frame::Users
        else
          Analytics::Frame::Default
        end
      end
    end
  end
end
