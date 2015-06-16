module Analytics
  # Factory class for a single frame (time period) table
  module Frame
    # Here we're skipping the totaling step because this already IS an iteration of the totaling step...
    class Totals
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def exec
        reduced_table
      end

      def reduced_table
        reducer.exec(base_table)
      end

      def base_table
        HashTable.new(base_data)
      end

      def base_data
        Analytics::ApiAdapter.get(query.exec)
      end

      def reducer
        Analytics::Reducer.for(options)
      end

      def query
        Analytics::Query.for(options)
      end
    end
  end
end
