module Analytics
  module Populator
    # Populates metrics table with time series data for a given metric
    class TimeSeries
      # returns metric by division and user type
      attr_reader :metric, :options, :frame_populator

      attr_accessor :start_month, :end_month

      def self.exec(options)
        new(options).exec
      end

      def initialize(options)
        @metric = options[:metric]
        @options = options
        @frame_populator = Analytics::Populator::Frame
        @start_month = Month.new(2014, 1)
        @end_month = Month.prev
      end

      def exec
        months.each do |month|
          puts "adding frame for month #{month.name}"

          frame_populator.add_frame(
            frame: month_table(month),
            dimensions: options[:dimensions],
            min_sessions: options[:min_sessions],
            metric: metric,
            month: month
          )
        end
      end

      def months
        @months = Month.for_interval(start_month, end_month)
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
end
