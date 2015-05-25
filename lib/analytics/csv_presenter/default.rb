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
          memo + rows_for_user_type(key)
        end
      end

      def division_labeler
        Analytics::Labeler::Id.new(
          Division.all,
          "User Division Not Found"
        )
      end

      def by_division
        rows = []

        rows << ([
          "All User Types",
          "All Divisions"
        ] + months.map {|month| abstract.total.first[month] })

        rows + abstract.by_division.inject([]) do |memo, division|
          memo << ([
            "",
            division_labeler.exec(division[:division_id])
          ] + months.map {|month| division[month] })
        end
      end

      def abstract_by_division
        abstract.rows.subsets{|row| row[:division_id] }
      end

      def rows_for_user_type(user_type)
        rows = []

        # Totals
        rows << [
          user_type_labeler.exec(user_type),
          "All Divisions"
        ] + months.map do |month|
          abstract.total_for_user_type(user_type.to_s).first[month]
        end

        # Breakdown by division
        abstract.user_type_divisions(user_type).each do |division|
          rows << [
            "",
            division_labeler.exec(division[:division_id])
          ] + months.map {|month| (division[month] || 0) }
        end

        rows
      end
    end
  end
end
