module Analytics
  module CsvPresenter
    # displays metrics by division and user type
    class Default < Base
      def exec
        headings + by_user_type + by_division
      end

      def metric
        @metric ||= Metric.transform_metric(options[:metric])
      end

      def data_source
        @data_source ||= QueryScope.new(Metric, metric: metric)
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
        result = []

        result << ([
          "All User Types",
          "All Divisions"
        ] + months.map {|month| data_source.aggregate({})[month] })

        divisional_breakdown = data_source.aggregate(breakdown_by: :division_id)
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
        result = []

        # Totals
        result << [
          user_type_labeler.exec(user_type),
          "All Divisions"
        ] + months.map do |month|
          data_source.aggregate(user_type_key: user_type)[month]
        end

        # Breakdown by division
        divisional_breakdown = data_source.
          aggregate(user_type_key: user_type, breakdown_by: :division_id)

        divisional_breakdown.each do |division|
          result << [
            "",
            division_labeler.exec(division.division_id)
          ] + months.map {|month| (division[month] || 0) }
        end

        result
      end
    end
  end
end
