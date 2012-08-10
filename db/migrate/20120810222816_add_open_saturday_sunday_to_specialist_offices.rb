class AddOpenSaturdaySundayToSpecialistOffices < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :open_saturday, :boolean, :default => false
    add_column :specialist_offices, :open_sunday, :boolean, :default => false
  end
end
