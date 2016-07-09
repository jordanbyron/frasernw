class RenameFocusesToClinicAreasOfPractice < ActiveRecord::Migration
  def change
    rename_table :focuses, :clinic_areas_of_practice
  end
end
