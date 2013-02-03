class AddIsPhysicanToSpecialist < ActiveRecord::Migration
  def change
    add_column :specialists, :is_gp, :boolean, :default => false
  end
end
