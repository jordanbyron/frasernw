class AddEmailToSpecialistsAndClinics < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :email, :string
    add_column :clinics, :email, :string
  end
end
