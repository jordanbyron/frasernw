class RenameCapacitiesToSpecialistAreasOfPractice < ActiveRecord::Migration
  def change
    rename_index :capacities,
      "index_capacities_on_procedure_specialization_id",
      "index_specialist_areas_of_practice_on_procedure_specialization"
    rename_table :capacities, :specialist_areas_of_practice
  end
end
