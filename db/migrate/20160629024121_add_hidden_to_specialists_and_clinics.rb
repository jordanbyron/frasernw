class AddHiddenToSpecialistsAndClinics < ActiveRecord::Migration
  def up
    add_column :specialists, :hidden, :boolean, default: false
    add_column :clinics, :hidden, :boolean, default: false
  end
end
