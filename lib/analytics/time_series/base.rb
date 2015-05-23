module Analytics
  # GOOGLE ANALYTICS
  # supported metrics:
  # :users, :users_min_5_sessions, :users_min_10_sessions, :average_session_duration, :average_page_view_duration, :page_views, :sessions

  # Factory class for a time series analytics table
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
        cache_fetch = Rails.cache.fetch(cache_key, force: options[:force]) do
          generate
        end

        Analytics::AnalyticsTable::Division.new(cache_fetch)
      end

      def generate
        table = months.inject(HashTable.new([])) do |memo, month|
          accumulate_to_table(memo, month)
        end

        months.each do |column|
          table.transform_column!(column) do |row|
            row[column].to_i
          end
        end

        table.rows
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
        month_table = Analytics::Frame.for(metric).exec(
          metric,
          dimensions,
          start_date: month.start_date,
          end_date: month.end_date
        )

        memo.add_column(
          other_table: month_table,
          keys_to_match: dimensions,
          old_column_key: metric,
          new_column_key: month
        )
      end
    end
  end
end
