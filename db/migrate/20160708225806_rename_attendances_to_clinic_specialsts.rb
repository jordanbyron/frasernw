class RenameAttendancesToClinicSpecialsts < ActiveRecord::Migration
  def change
    rename_index :attendances,
      "index_attendances_on_clinic_location_id_and_specialist_id",
      "index_clinic_specialists_on_clinic_location_and_specialist"
    rename_index :attendances,
      "index_attendances_on_clinic_id",
      "index_clinic_specialists_on_clinic_id"
    rename_table :attendances, :clinic_specialists
  end
end
