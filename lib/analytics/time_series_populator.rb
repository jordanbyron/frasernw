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
      cache_fetch = Rails.cache.fetch(cache_key) do
        generate
      end

      Analytics::AnalyticsTable.new(cache_fetch)
    end


    def months
      @months = Month.for_interval(START_MONTH, end_month)
    end

    def end_month
      Month.prev
    end

    def generate
      table = months.each do |month|
        puts "frame for #{month.name}"

        t = month_table(month)
        puts "adding table for #{month.name}, row count #{t.rows.count}"


        frame_populator.add_frame(
          frame: t,
          keys_to_match: options[:dimensions],
          metric: metric,
          month: month
        )
      end

      # need to cast to int first
      months.each do |column|
        table.transform_column!(column) do |row|
          row[column].to_i
        end
      end

      table.rows
    end


    def month_table(month)
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
