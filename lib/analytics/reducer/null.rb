module Analytics
  module Reducer
    class Null
      def initialize(table, options = {})
        @table = table
      end

      def exec
        table
      end
    end
  end
end
