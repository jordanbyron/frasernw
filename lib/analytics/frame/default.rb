module Analytics
  # Factory class for a single frame (time period) table
  module Frame
    class Default
      attr_reader :query, :totaler, :reducer

      def initialize(query, reducer, totaler)
        @query = query
        @totaler = totaler
        @reducer = reducer
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
    end
  end
end
