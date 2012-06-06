class AddAttionalDetailsToSpecialists < ActiveRecord::Migration
  def change
    add_column :specialists, :hospital_clinic_details, :text
  end
end
