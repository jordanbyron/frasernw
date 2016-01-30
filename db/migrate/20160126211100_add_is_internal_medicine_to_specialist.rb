class AddIsInternalMedicineToSpecialist < ActiveRecord::Migration
  def change
    add_column :specialists, :is_internal_medicine, :boolean, :default => false
  end
end
