class RemoveColumnsFromProcedure < ActiveRecord::Migration
  def change
    remove_column :procedures, :done_by_clinics
    remove_column :procedures, :done_by_specialists
  end
end
