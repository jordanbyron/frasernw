class AddPhoneExtensionToHospitalsAndClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :phone_extension, :string
    add_column :hospitals, :phone_extension, :string
  end
end
