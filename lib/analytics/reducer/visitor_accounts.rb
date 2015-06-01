module Analytics
  module Reducer
    # Collapses a user id dimension down to a 'users' metric
    class VisitorAccounts
      attr_reader :table, :dimensions, :min_sessions, :options

      def initialize(options = {})
        @dimensions = options[:dimensions]
        @min_sessions = options[:min_sessions] || 0
        @options = options
      end

      def returned_metric
        @returned_metric ||= begin
          if options[:dimensions].include? :page_path
            :page_views
          else
            :sessions
          end
        end
      end

      def exec(table)
        puts "reducing #{returned_metric} to #{options[:metric]}, dimensions: #{dimensions}"
        new_table = table.collapse_subsets(comparator, base_accumulator, accumulator_function)
        puts "starting with #{table.rows.count}"
        puts "reduced to #{new_table.rows.count}"
        new_table
      end

      def comparator
        Proc.new do |row|
          dimensions.map { |dimension| row[dimension] }
        end
      end

      def base_accumulator
        {
          :visitor_accounts => 0
        }
      end

      def accumulator_function
        Proc.new do |accumulator, row|
          dimensions.inject({}) do |memo, dimension|
            memo.merge(dimension => row[dimension])
          end.merge(:visitor_accounts => new_metric_value(row, accumulator) )
        end
      end

      def new_metric_value(row, accumulator)
        if min_sessions < row[returned_metric].to_i
          accumulator[:visitor_accounts] + 1
        else
          accumulator[:visitor_accounts]
        end
      end
    end
  end
end
