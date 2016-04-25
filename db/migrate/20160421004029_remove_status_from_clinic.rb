class RemoveStatusFromClinic < ActiveRecord::Migration
  def up
    remove_column :clinics, :status
  end

  def down
    add_column :clinics, :status, :text
  end
end
