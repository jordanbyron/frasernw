module Analytics
  # takes a table, returns a filtered table
  module Filter
    class Base
      attr_reader :table, :filter

      def initialize(filter)
        @filter = filter
      end

      def exec(table)
        @table = table
      end
    end
  end
end
