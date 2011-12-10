class AddFieldsToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :is_specialist, :boolean, :default => true
    add_column :attendances, :freeform_firstname, :string
    add_column :attendances, :freeform_lastname, :string
    add_column :attendances, :area_of_focus, :string
  end
end
