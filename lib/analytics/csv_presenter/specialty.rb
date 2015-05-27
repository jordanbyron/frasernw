# takes an abstract table, applies any necessary filters to it, and outputs table in array format (which the csv service can handle)

module Analytics
  module CsvPresenter
    # displays metrics by specialty name and user type
    class Specialty < Base
      attr_reader :options

      def exec
        headings + body_rows
      end

      def abstract
        @abstract ||= Analytics::TimeSeries.exec(
          metric: options[:metric],
          dimensions: options[:dimensions].except(:specialty).push(:page_path, :division_id),
          force: true
        )
      end

      def filters
        puts options[:division_id]

        [
          Analytics::Filter::Search.new(division_id: options[:division_id]),
          Analytics::Filter::PathMatch.new(
            path_regexp: /\/specialties\/[[:digit:]]+/
          )
        ]
      end

      def headings
        [
          [ title ],
          (["Specialty", "User Type"] + months.map(&:name))
        ]
      end

      def specialty_labeler
        @specialty_labeler ||= Analytics::Labeler::Path.new(
          Specialization.all,
          "/specialties/"
        )
      end

      def body_rows
        filtered.rows.subsets do |row|
          row[:page_path]
        end.inject([]) do |memo, rows_for_path|
          for_path(AnalyticsTable.new(rows_for_path))
        end
      end

      def for_path(abstract_rows)
        all_user_types = abstract_rows.search(user_type_key: nil).rows.first
        user_type_breakdown = abstract_rows.breakdown_by(:user_type_key).rows

        rows = [
          ([
            specialty_labeler.exec(all_user_types[:page_path]),
            "All user types",
          ] + months.map {|month| all_user_types[month] })
        ]

        rows << user_type_breakdown.inject([]) do |memo, row|
          memo << ([
            "",
            user_type_labeler.exec(row[:user_type_key]),
          ] + months.map {|month| row[month] })
        end
      end
    end
  end
end
