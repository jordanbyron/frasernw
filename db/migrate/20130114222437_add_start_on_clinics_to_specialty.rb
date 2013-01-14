class AddStartOnClinicsToSpecialty < ActiveRecord::Migration
  def change
    add_column :specializations, :open_to_clinic_tab, :boolean, :default => false
  end
end
