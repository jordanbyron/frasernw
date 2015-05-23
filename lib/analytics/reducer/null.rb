module Analytics
  module Reducer
    class Null
      def initialize(options={})
        @table = options[:table]
      end

      def exec
        table
      end
    end
  end
end
