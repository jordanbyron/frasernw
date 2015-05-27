# filter down by division, if there is a division
# filter down by path to resource category
# takes an abstract table, applies any necessary filters to it, and outputs table in array format (which the csv service can handle)
module Analytics
  module CsvPresenter
    # displays metrics by specialty name and user type
    class Resource < Base
      attr_reader :options

      def exec
        headings + body_rows
      end

      def parsed_dimensions
        options[:dimensions].delete(:resource_category).push(:page_path, :division_id)
      end

      def abstract
        @abstract ||= Analytics::TimeSeries.exec(
          metric: options[:metric],
          dimension: parsed_dimensions,
          force: true
        )
      end

      def filters
        [
          Analytics::Filter::Search.new(division_id: options[:division_id]),
          Analytics::Filter::PathMatch.new(
            path_regexp: /\/content_items\/[[:digit:]]+/
          )
        ]
      end

      def headings
        [
          [ title ],
          (["Specialty", "User Type"] + months.map(&:name))
        ]
      end

      def resource_labeler
        @resource_labeler ||= Analytics::Labeler::Resource.new
      end

      def body_rows
        filtered.rows.subsets do |row|
          row[:page_path]
        end.inject([]) do |memo, rows_for_path|
          for_path(Table.new(rows_for_path))
        end
      end

      def for_path(abstract_rows)
        all_user_types = abstract_rows.search(user_type_key: nil).rows.first
        user_type_breakdown = abstract_rows.breakdown_by(:user_type_key).rows
        resource_label = resource_labeler.exec(all_user_types[:page_path])

        result = [
          ([
            resource_label[:resource],
            resource_label[:category],
            "All user types",
          ] + months.map {|month| all_user_types[month] })
        ]

        result + user_type_breakdown.inject([]) do |memo, row|
          memo << ([
            "",
            user_type_labeler.exec(row[:user_type_key]),
          ] + months.map {|month| row[month] })
        end
      end
    end
  end
end
