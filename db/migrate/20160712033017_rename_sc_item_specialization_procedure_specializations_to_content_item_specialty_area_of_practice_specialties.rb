class RenameScItemSpecializationProcedureSpecializationsToContentItemSpecialtyAreaOfPracticeSpecialties < ActiveRecord::Migration
  def change
    rename_index :sc_item_specialization_procedure_specializations,
      "index_sc_item_s_p_s_on_psid_sc_item_s_id",
      "index_co_item_specialty_aop_specialty_on_aop_co_item_specialty"
    rename_index :sc_item_specialization_procedure_specializations,
      "index_sc_item_sps_on_procedure_specialization_id",
      "index_content_item_specialty_aop_specialty_on_aop_specialty"
    rename_index :sc_item_specialization_procedure_specializations,
      "index_sc_item_sps_on_sc_item_specialization_id",
      "index_con_item_specialty_aop_specialty_on_con_item_specialty"
    rename_table :sc_item_specialization_procedure_specializations,
      :content_item_specialty_area_of_practice_specialties
  end
end
