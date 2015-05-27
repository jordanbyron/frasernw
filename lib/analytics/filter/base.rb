module Analytics
  # takes a table, returns a filtered table
  module Filter
    class Base
      attr_reader :filter

      def initialize(filter)
        @filter = filter
      end
    end
  end
end
