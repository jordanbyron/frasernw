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
        @data_source ||= QueryScope.new(
          Metric,
          metric: options[:metric],
          division_id: options[:division_id],
          path_regexp: '/specialties/\d+'
        )
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

      def specialty_paths
        @paths ||= data_source.all.map(&:page_path)
      end

      def body_rows
        specialty_paths.inject([]) do |memo, path|
          memo + for_path(path)
        end
      end

      def for_path(abstract_rows)
        total = data_source.aggregate(page_path: path)
        breakdown = data_source.aggregate(
          page_path: path,
          breakdown: :user_type_key
        )
        specialty_label = specialty_labeler.exec(total.page_path)

        result = [
          ([
            path,
            specialty_label[:specialty],
            specialty_label[:category],
            "All user types",
          ] + months.map {|month| total[month] })
        ]

        result + breakdown.inject([]) do |memo, row|
          memo << ([
            "",
            "",
              user_type_labeler.exec(row.user_type_key),
          ] + months.map {|month| row[month] })
        end
      end
    end
  end
end
