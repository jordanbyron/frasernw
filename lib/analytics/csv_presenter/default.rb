module Analytics
  module CsvPresenter
    # displays metrics by division and user type
    class Default < Base
      def exec
        headings + by_user_type + by_division
      end

      def metric
        @metric ||= Metric.transform_metric(
          options[:metric],
          options.slice(*:min_sessions)
        )
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
        ] + months.map do |month|
          data_source.aggregate({}).first.safe_val(month)
        end)

        divisional_breakdown = data_source.aggregate(breakdown: :division_id)
        result + divisional_breakdown.inject([]) do |memo, division|
          memo << ([
            "",
            division_labeler.exec(division.division_id)
          ] + months.map {|month| division.safe_val(month) })
        end
      end

      def division_labeler
        @division_labeler ||= Analytics::Labeler::Id.new(
          Division.all,
          fallback_message: "User Division Not Found"
        )
      end

      def for_user_type(user_type)
        result = []

        # Totals
        total = data_source.aggregate(user_type_key: user_type)
        result << [
          user_type_labeler.exec(user_type),
          "All Divisions"
        ] + months.map do |month|
          total.first.safe_val(month)
        end

        # Breakdown by division
        divisional_breakdown = data_source.
          aggregate(user_type_key: user_type, breakdown: :division_id)

        divisional_breakdown.each do |division|
          result << [
            "",
            division_labeler.exec(division.division_id)
          ] + months.map {|month| division.safe_val(month) }
        end

        result
      end
    end
  end
end
