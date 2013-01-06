class AddPerProcedureWaitTimes < ActiveRecord::Migration
  def change
    add_column :procedure_specializations, :specialist_wait_time, :boolean, :default => false
    add_column :procedure_specializations, :clinic_wait_time, :boolean, :default => false
    add_column :capacities, :waittime_mask, :integer, :default => 0
    add_column :capacities, :lagtime_mask, :integer, :default => 0
    add_column :focuses, :waittime_mask, :integer, :default => 0
    add_column :focuses, :lagtime_mask, :integer, :default => 0
  end
end
