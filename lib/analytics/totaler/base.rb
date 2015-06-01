module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table
    class Base
      attr_reader :table, :dimensions, :metric

      def initialize(options)
        @dimensions = options[:dimensions]
        @metric = options[:metric]
      end

      def totals(table)
        @table = table

        combinations.inject([]) do |memo, combination|
          memo + total_combination(combination)
        end
      end

      def combinations
        dimensions.combinations(dimensions.length - 1)
      end
    end
  end
end
