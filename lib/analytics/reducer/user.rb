module Analytics
  module Reducer
    # Collapses a user id dimension down to a 'users' metric
    class User
      attr_reader :table, :dimensions, :min_sessions

      def initialize(options = {})
        @table = options[:table]
        @dimensions = options[:dimensions]
        @min_sessions = options[:min_sessions]
      end

      def exec
        table.collapse_subsets(comparator, base_accumulator, accumulator_function)
      end

      def comparator
        Proc.new do |row|
          dimensions.map { |dimension| row[dimension] }
        end
      end

      def base_accumulator
        {
          :users => 0
        }
      end

      def accumulator_function
        Proc.new do |accumulator, row|
          dimensions.inject({}) do |memo, dimension|
            memo.merge(dimension => row[dimension])
          end.merge(:users => new_metric_value(row, accumulator) )
        end
      end

      def new_metric_value(row, accumulator)
        if options[:min_sessions] < row[:sessions]
          accumulator[:users] + 1
        else
          accumulator[:users]
        end
      end
    end
  end
end
