# gets an abstract table (array of hashes) and converts it to an array of arrays, a format the CSV service can handle
# displays metrics by division and user type
module Analytics
  module CsvPresenter
    class Base
      attr_reader :options

      def self.exec(options)
        new(options).exec
      end

      def initialize(options)
        @options = options
      end

      def exec
        headings + for_user_types + for_divisions
      end

      def abstract
        @abstract ||= Analytics::TimeSeries.exec(
          options[:metric],
          force: true
        )
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
          (["User type", "Division"] + months.map(&:name))
        ]
      end

      def for_user_types
        Analytics::ApiAdapter.user_type_keys.inject([]) do |memo, key|
          memo + rows_for_user_type(key)
        end
      end

      def for_divisions
        rows = []

        rows << ([
          "All User Types",
          "All Divisions"
        ] + months.map {|month| abstract.total.first[month] })

        rows + abstract.by_division.inject([]) do |memo, division|
          memo << ([
            "",
            division_from_id(division[:division_id])
          ] + months.map {|month| division[month] })
        end
      end

      def months
        @months ||= Month.for_interval(
          options[:start_month],
          options[:end_month]
        )
      end

      def abstract_by_division
        abstract.rows.subsets{|row| row[:division_id] }
      end

      def divisions
        @divisions ||= Division.all
      end

      def division_from_id(id)
        division = divisions.find {|division| division.id == id.to_i }

        if !division.nil?
          division.name
        else
          "No Division"
        end
      end

      def rows_for_user_type(user_type)
        rows = []

        # Totals
        rows << [
          Analytics::ApiAdapter.user_type_from_key(user_type),
          "All Divisions"
        ] + months.map do |month|
          abstract.total_for_user_type(user_type.to_s).first[month]
        end

        # Breakdown by division
        abstract.user_type_divisions(user_type).each do |division|
          rows << [
            "",
            division_from_id(division[:division_id])
          ] + months.map {|month| (division[month] || 0) }
        end

        rows
      end
    end
  end
end
