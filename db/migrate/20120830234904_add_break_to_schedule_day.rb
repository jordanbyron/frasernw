class AddBreakToScheduleDay < ActiveRecord::Migration
  def change
    add_column :schedule_days, :break_from, :time
    add_column :schedule_days, :break_to, :time
  end
end
