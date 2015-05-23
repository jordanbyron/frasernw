module Analytics
  module CsvPresenter
    # displays metrics by division and user type
    class Specialty
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        headings + body_rows
      end

      def abstract
        @abstract ||= Analytics::TimeSeries.exec(
          metric: options[:metric],
          dimension: options[:dimensions].delete(:specialty).push(:page_path)
          force: true
        )

        # Filter by division, if there is a division
        # Filter by path down to specialty
      end

      def date_options
        options.slice(:start_month, :end_month)
      end

      def title
        options[:title]
      end

      def headings
        [
          [ title ],
          (["Specialty", "User Type"] + months.map(&:name))
        ]
      end

      def for_division
        @for_division ||= abstract.search division_id: options[:division_id]
      end

      def subsets_by_
      end

      def body_rows
        for_division.rows.subsets do |row|
          row[:
        end
      end


      def months
        @months ||= Month.for_interval(
          options[:start_month],
          options[:end_month]
        )
      end

    end
  end
end
