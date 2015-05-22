module Analytics
  module Frame
    # Users are a special case because they aren't a GA metric --> can't be counted directly
    class Users < Base
      def exec
        table = by_division_and_user_type
        table = table.add_rows(sums_by_user_type)
        table = table.add_rows(sums_by_division)
        table = table.add_rows([grand_total])

        table
      end

      def by_division_and_user_type
        return @by_division_and_user_type if defined? @by_division_and_user_type

        data = Analytics::ApiAdapter.get({
          metrics: [:sessions, :page_views, :average_session_duration, :average_page_view_duration],
          dimensions: [:user_id, :user_type_key, :division_id]
        }.merge(options.slice(:start_date, :end_date)))

        @by_division_and_user_type = HashTable.new(data).collapse_subsets(
          Proc.new { |row| [ row[:user_type_key], row[:division_id] ]  },
          {
            :user_type_key => nil,
            :division_id => nil,
            metric => 0
          },
          Proc.new do |accumulator, row|
            accumulator.dup.merge(
              :user_type_key => row[:user_type_key],
              :division_id => row[:division_id],
              metric => value(row, accumulator)
            )
          end
        )
      end

      # TODO better naming
      def value(row, accumulator)
        case metric
        when :users
          accumulator[metric] + 1
        when :users_min_5_sessions
          row[:sessions].to_i > 5 ? (accumulator[metric] + 1) : accumulator[metric]
        when :users_min_10_sessions
          row[:sessions].to_i > 10 ? (accumulator[metric] + 1) : accumulator[metric]
        else
          raise "Don't know that metric"
        end
      end

      def sums_by_user_type
        by_division_and_user_type.rows.subsets do |row|
          row[:user_type_key]
        end.inject([]) do |memo, set|
          sum = set.inject(0) do |memo, row|
            if row[:division_id].present?
              memo += row[metric].to_i
            else
              memo
            end
          end

          memo << {
            :user_type_key => set.first[:user_type_key],
            metric => sum
          }
        end
      end

      def sums_by_division
        by_division_and_user_type.rows.subsets do |row|
          row[:division_id]
        end.inject([]) do |memo, set|
          sum = set.inject(0) do |memo, row|
            if row[:user_type_key].present?
              memo += row[metric].to_i
            else
              memo
            end
          end

          memo << {
            :division_id => set.first[:division_id],
            metric => sum
          }
        end
      end

      def grand_total
        sum = HashTable.sum_column(by_division_and_user_type.rows, metric)
        {
          :division_id => nil,
          :user_type_key => nil,
          metric => sum
        }
      end
    end
  end
end
