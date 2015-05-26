module Analytics
  # Factory class for a single frame (time period) table
  module Frame
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        reduced_table.add_rows(totals)
      end

      def totals
        puts "totaling"

        totaler.new(reduced_table, options).totals
      end

      def reduced_table
        puts "reducing"

        @reduced_table ||= reducer.new(base_table, options).exec
      end

      # Unreduced, without toals
      def base_data
        Analytics::ApiAdapter.get(query)
      end

      def base_table
        @base_table ||= HashTable.new(base_data)
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
