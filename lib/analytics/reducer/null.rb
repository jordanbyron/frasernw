module Analytics
  module Reducer
    class Null
      def initialize(options = {})
      end

      def exec(table)
        table
      end
    end
  end
end
