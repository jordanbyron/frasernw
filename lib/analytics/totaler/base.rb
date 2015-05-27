module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table
    class Base
      attr_reader :table, :dimensions, :metric, :options

      def initialize(table, options)
        @table = table
        @dimensions = options[:dimensions]
        @metric = options[:metric]
        @options = options
      end

      def totals
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
