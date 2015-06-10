module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table
    class Base
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def totals(table)
        puts "totaling #{options[:metric]}"
        combinations.inject([]) do |memo, combination|
          memo + total_combination(combination)
        end
      end

      def dimensions
        options[:dimensions]
      end

      def combinations
        dimensions.combinations(dimensions.length - 1)
      end
    end
  end
end
