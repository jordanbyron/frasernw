module CsvReport
  module Presenters
    class SpecialistWaittimes

      def exec
        headings + totals + divisional_breakdown
      end

      def headings
        [
          [ "Specialist Waittimes" ],
          [ "Division" ] + WaitTime.labels + [ "Median" ]
        ]
      end

      def totals
        [ [ "All" ] + WaitTime.counts + [ WaitTime.median ] ]
      end

      def divisional_breakdown
        Division.all.map do |division|
          row(division)
        end
      end

      def row(division)
        [ division.name ] + division.waittime_counts + [ division.median_waittime ]
      end
    end
  end
end
