module Analytics
  module Populator
    # Populates populates a table with a row
    class Row
      attr_reader :row, :table, :options, :metric

      def self.add_row(row, options)
        new(row, options).exec
      end

      def initialize(row, options)
        @row = row
        @options = options
        @metric = options[:metric]
        @table = Metric
      end

      def exec
        if existing_row.present?
          existing_row.update_attribute(column_key, row[metric])
        else
          table.create new_row_attrs
        end
      end

      def existing_row
        @existing_row ||= table.aggregate_find(query)
      end

      def new_row_attrs
        query.merge(column_key => row[metric])
      end

      def query
        @query ||= row.
          slice(*Metric::DIMENSIONS).
          merge(month_stamp: options[:month].to_i)
      end

      def column_key
        if options[:min_sessions].nil?
          metric
        else
          "#{metric}_min#{options[:min_sessions]}sessions"
        end.to_sym
      end
    end
  end
end
