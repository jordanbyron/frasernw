module Reporter
  module ByDivisionAndUserType
    # Users are a special case because they aren't a GA metric --> can't be counted directly
    class Users < Base
      def self.period(metric, options)
        data = AnalyticsApiAdapter.get({
          metrics: [:sessions, :page_views, :average_session_duration, :average_page_view_duration],
          dimensions: [:user_id, :user_type_key, :division_id]
        }.merge(options.slice(:start_date, :end_date)))

        Table.new(data).collapse_subsets(
          Proc.new { |row| [ row[:user_type_key], row[:division_id] ]  },
          {
            user_type_key: nil,
            division_id: nil,
            value: 0
          },
          Proc.new do |accumulator, row|
            accumulator.dup.merge(
              user_type_key: row[:user_type_key],
              division_id: row[:division_id],
              value: value(metric, row, accumulator)
            )
          end
        )
      end

      # Pass a proc as a param instead?
      def self.value(metric, row, accumulator)
        case metric
        when :users
          accumulator[:value] + 1
        when :users_min_5_sessions
          row[:sessions].to_i > 5 ? (accumulator[:value] + 1) : accumulator[:value]
        when :users_min_10_sessions
          row[:sessions].to_i > 10 ? (accumulator[:value] + 1) : accumulator[:value]
        else
          raise "Don't know that metric"
        end
      end
    end
  end
end
