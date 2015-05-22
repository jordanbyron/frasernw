module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table

    class Base
      attr_reader :original_table, :dimensions, :metric, :options

      def initialize(original_table, dimensions, metric)
        @original_table = options[:original_table]
        @dimensions = options[:dimensions]
        @metric = options[:metric]
        @options = options
      end

      def totals
        dimensions.combinations.inject([]) do |memo, permutation|
          memo << total_permutation(permutation)
        end
      end
    end
  end
end
