module Analytics
  # Factory class for a time series analytics table
  class TimeSeries
    # TODO get actual start month
    START_MONTH = Month.new(2014, 1)

    # returns metric by division and user type
    attr_reader :metric, :options

    def self.exec(options)
      new(options).exec
    end

    def initialize(options)
      @metric = options[:metric]
      @options = options
    end

    def exec
      cache_fetch = Rails.cache.fetch(cache_key, force: options[:force]) do
        generate
      end

      Analytics::AnalyticsTable::Division.new(cache_fetch)
    end

    def cache_key
      "abstract_analytics_table:base:#{metric.to_s}:#{dimensions_cache_key}:#{Month.current.to_cache_key}"
    end

    def months
      @months = Month.for_interval(START_MONTH, end_month)
    end

    def end_month
      Month.prev
    end

    def dimensions_cache_key
      dimensions.map(&:to_s).sort.join(":")
    end

    def generate
      table = months.inject(HashTable.new([])) do |memo, month|
        memo.add_column(
          other_table: month_table(month),
          keys_to_match: options[:dimensions],
          old_column_key: metric,
          new_column_key: month
        )
      end

      months.each do |column|
        table.transform_column!(column) do |row|
          row[column].to_i
        end
      end

      table.rows
    end


    def month_table
      Analytics::Frame.exec frame_options(month)
    end

    def frame_options(month)
      options.slice(:metric, :dimensions, :min_sessions).merge(
        start_date: month.start_date,
        end_date: month.end_date
      )
    end
  end
end
