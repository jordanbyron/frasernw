module Analytics
  module Totaler
    # generates totals across dimensions for one a one-frame table

    class Sum < Base
      def total_combination(combination)
        table.rows.subsets do |row|
          combination.map { |dimension| row[dimension] }
        end.inject([]) do |memo, set|
          memo << total_set(set, combination)
        end
      end

      def total_set(set, combination)
        sum = set.inject(0) do |memo, row|
          memo += row[metric].to_i
        end

        set.first.slice(*combination).merge(metric => sum)
      end
    end
  end
end
