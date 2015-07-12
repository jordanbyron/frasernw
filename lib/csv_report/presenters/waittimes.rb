module CsvReport
  module Presenters
    class Waittimes
      attr_reader :reporter, :model

      def initialize(model)
        @model = model
        @reporter = WaitTimeReporter.new(model)
      end

      def exec
        headings + totals + divisional_breakdown
      end

      def headings
        [
          [ "#{model.to_s} Waittimes" ],
          [ "Division" ] + reporter.labels + [ "Median" ]
        ]
      end

      def totals
        [ [ "All" ] + reporter.counts + [ reporter.median ] ]
      end

      def divisional_breakdown
        Division.all.map do |division|
          row(division)
        end
      end

      def row(division)
        [ division.name ] + division.waittime_counts(model) + [ division.median_waittime(model) ]
      end
    end
  end
end
