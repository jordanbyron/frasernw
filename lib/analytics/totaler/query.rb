module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table
    class Query < Base
      def total_combination(combination)
        puts "totaling combination #{combination}"

        Analytics::Frame::Totals.new(
          combination_options(combination)
        ).exec.rows
      end

      def combination_options(combination)
        options.merge(dimensions: combination)
      end
    end
  end
end
