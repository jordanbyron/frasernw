class RemoveOldUserControls < ActiveRecord::Migration
  def up
    drop_table :user_controls_clinic_locations
    drop_table :user_controls_specialist_offices
  end
end
