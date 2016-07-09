class RenamePrivilegesToHospitalSpecialists < ActiveRecord::Migration
  def change
    rename_table :privileges, :hospital_specialists
  end
end
