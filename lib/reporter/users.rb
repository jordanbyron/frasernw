module Reporter
  # number of users by user type and then division
  class Users
    def self.time_series(options)
      Month.for_interval(options[:start_month], options[:end_month]).inject(Table.new([])) do |table, month|
        month_table = period(
          start_date: month.start_date,
          end_date: month.end_date,
          min_sessions: (options[:min_sessions] || 0)
        )
        table.add_column(
          other_table: month_table,
          keys_to_match: [:division_id, :user_type_key],
          old_column_key: :users,
          new_column_key: month
        )
      end
    end

    def self.period(options)
      data = AnalyticsApiAdapter.get({
        metrics: [:sessions],
        dimensions: [:user_id, :user_type_key, :division_id]
      }.merge(options.slice(:start_date, :end_date)))

      Table.new(data).collapse_subsets(
        Proc.new { |row| [ row[:user_type_key], row[:division_id] ]  },
        {
          user_type_key: nil,
          division_id: nil,
          users: 0
        },
        Proc.new do |accumulator, row|
          accumulator.dup.merge(
            user_type_key: row[:user_type_key],
            division_id: row[:division_id],
            users: (row[:sessions].to_i > options[:min_sessions] ? (accumulator[:users] += 1) : accumulator[:users])
          )
        end
      )
    end
  end
end
