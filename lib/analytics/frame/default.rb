module Analytics
  # Factory class for a single frame (time period) table
  module Frame
    class Default
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        reduced_table.add_rows(totals)
      end

      def totals
        totaler.totals(reduced_table)
      end

      def reduced_table
        @reduced_table ||= reducer.exec(base_table)
      end

      def base_table
        @base_table ||= HashTable.new(base_data)
      end

      # Unreduced, without toals
      def base_data
        Analytics::ApiAdapter.get(query.exec)
      end

      def reducer
        Analytics::Reducer.for(options)
      end

      def query
        Analytics::Query.for(options)
      end

      def totaler
        Analytics::Totaler.for(options)
      end
    end
  end
end
