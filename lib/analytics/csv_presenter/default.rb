module Analytics
  module CsvPresenter
    # displays metrics by division and user type
    class Default
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        headings + by_user_type + by_division
      end

      def abstract
        @abstract ||= Analytics::TimeSeries.exec(options.merge(force: true))
      end

      def headings
        [
          [ title ],
          (["User type", "Division"] + months.map(&:name))
        ]
      end

      def by_user_type
        Analytics::ApiAdapter.user_type_keys.inject([]) do |memo, key|
          memo + for_user_type(key)
        end
      end

      def by_division
        grand_total = abstract.
          search(user_type_key: nil, :division_id: nil).
          first

        divisional_breakdown = abstract.
          search(user_type_key: nil).
          exists(:division_id).
          rows

        result = []

        result << ([
          "All User Types",
          "All Divisions"
        ] + months.map {|month| grand_total[month] })

        result + divisional_breakdown.inject([]) do |memo, division|
          memo << ([
            "",
            division_labeler.exec(division[:division_id])
          ] + months.map {|month| division[month] })
        end
      end

      def division_labeler
        Analytics::Labeler::Id.new(
          Division.all,
          fallback_message: "User Division Not Found"
        )
      end

      def for_user_type(user_type)
        abstract_rows = abstract.search(user_type_key: user_type)
        abstract_total_row = abstract_rows.total_across(:division_id).rows.first
        abstract_divisional_rows = abstract_rows.breakdown_by(:division_id).rows

        result = []

        # Totals
        result << [
          user_type_labeler.exec(user_type),
          "All Divisions"
        ] + months.map do |month|
          abstract_total_row[month]
        end

        # Breakdown by division
        abstract_divisional_rows.each do |division|
          result << [
            "",
            division_labeler.exec(division[:division_id])
          ] + months.map {|month| (division[month] || 0) }
        end

        result
      end
    end
  end
end
