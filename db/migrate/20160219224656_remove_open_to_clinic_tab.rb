class RemoveOpenToClinicTab < ActiveRecord::Migration
  def up
    remove_column :specialization_options, :open_to_clinic_tab_old
  end

  def down
    add_column :specialization_options, :open_to_clinic_tab_old, :boolean
  end
end
