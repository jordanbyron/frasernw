module Reporter
  # number of users by user type and then division
  class UserTypeUsers
    def self.time_series(start_month, end_month)
      Month.for_interval(start_month, end_month).inject(Table.new([])) do |table, month|
        month_table = period(
          start_date: month.start_date,
          end_date: month.end_date
        )
        table.add_column(
          other_table: month_table,
          keys_to_match: [:division_id, :user_type_key],
          old_column_key: :users,
          new_column_key: month
        )
      end
    end

    def self.period(date_opts)
      # we're asking for page views b.c. analytics needs a metric, even though we're only really interested in user ids
      data = AnalyticsApiAdapter.get({
        metrics: [:page_views],
        dimensions: [:user_id, :division_id]
      }.merge(date_opts))

      Table.new(data).collapse_subsets(
        Proc.new { |row| [ row[:user_type_key], row[:division_id] ]  },
        {
          division_id: nil,
          users: 0
        },
        Proc.new do |accumulator, row|
          accumulator.dup.merge(
            user_type_key: row[:user_type_key],
            division_id: row[:division_id],
            users: accumulator[:users] += 1
          )
        end
      )
    end
  end
end
