module Analytics
  # Factory class for a single frame (time period) table
  module Frame
    class Base
      attr_reader :metric, :options

      def initialize(metric, options)
        @metric = metric
        @options = options
      end

      def exec
        reduced_table.add_rows(totals)
      end

      def totals
        totaler.exec(reduced_table)
      end

      def reduced_table
        @reduced_table ||= reducer.exec(base_table, options)
      end

      # Unreduced, without toals
      def base_data
        Analytics::ApiAdapter.get(query)
      end

      def base_table
        HashTable.new(base_data)
      end

      def query
        raise NotImplementedError
      end

      def totaler
        raise NotImplmeentedError
      end

      def reducer
        raise NotImplementedError
      end
    end
  end
end
