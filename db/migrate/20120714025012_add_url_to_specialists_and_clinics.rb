class AddUrlToSpecialistsAndClinics < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :url, :string
    add_column :clinics, :url, :string
  end
end
