class RemoveOpenToClinicTab < ActiveRecord::Migration
  def up
    remove_column :specialization_options, :open_to_clinic_tab_old
  end

  def down
  end
end
