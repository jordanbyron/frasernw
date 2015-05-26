module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table
    class Base
      attr_reader :table, :dimensions, :metric

      def initialize(table, options)
        @table = table
        @dimensions = options[:dimensions]
        @metric = options[:metric]
      end

      def totals
        dimensions.combinations.inject([]) do |memo, combination|
          memo + total_combination(combination)
        end
      end
    end
  end
end
