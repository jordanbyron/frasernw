module Analytics
  class UserReducer
    # TODO Args

    def initialize(table, dimensions, min_sessions)
      options[:min_sessions] ||= 0
    end

    def exec
      table.collapse_subsets(comparator, base_accumulator, accumulator_function)
    end

    def remaining_dimensions
      @remaining_dimensions ||= dimensions - [ :user_id ]
    end

    def comparator
      Proc.new do |row|
        remaining_dimensions.map { |dimension| row[dimension] }
      end
    end

    def base_accumulator
      {
        :users => 0
      }
    end

    def accumulator_function
      Proc.new do |accumulator, row|
        remaining_dimension.inject({}) do |memo, dimension|
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
