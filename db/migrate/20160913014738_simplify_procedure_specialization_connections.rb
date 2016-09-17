class SimplifyProcedureSpecializationConnections < ActiveRecord::Migration
  def change
    add_column :procedures, :specialist_has_wait_time, :boolean, default: false
    add_column :procedures, :clinic_has_wait_time, :boolean, default: false
    Procedure.reset_column_information
    ProcedureSpecialization.
      where('procedure_specializations.specialist_wait_time = (?)', true).
      each do |procedure_spec|
        procedure_spec.procedure.update_attributes!(
          specialist_has_wait_time: procedure_spec.specialist_wait_time
        )
      end
    ProcedureSpecialization.
      where('procedure_specializations.clinic_wait_time = (?)', true).
      each do |procedure_spec|
        procedure_spec.procedure.update_attributes!(
          clinic_has_wait_time: procedure_spec.clinic_wait_time
        )
      end
    remove_column :procedure_specializations, :specialist_wait_time
    remove_column :procedure_specializations, :clinic_wait_time

    add_column :capacities, :procedure_id, :integer
    Capacity.reset_column_information
    Capacity.all.reject do |capacity|
      capacity.procedure_specialization_id.blank?
    end.each do |capacity|
      procedure_specialization =
        ProcedureSpecialization.find(capacity.procedure_specialization_id)
      capacity.update_attributes!(
        procedure_id: procedure_specialization.procedure_id
      )
    end
    remove_column :capacities, :procedure_specialization_id
    add_index :capacities, :procedure_id

    add_column :focuses, :procedure_id, :integer
    Focus.reset_column_information
    Focus.all.reject do |focus|
      focus.procedure_specialization_id.blank?
    end.each do |focus|
      procedure_specialization =
        ProcedureSpecialization.find(focus.procedure_specialization_id)
      focus.update_attributes!(
        procedure_id: procedure_specialization.procedure_id
      )
    end
    remove_column :focuses, :procedure_specialization_id
    add_index :focuses, :procedure_id

    add_column :sc_item_specialization_procedure_specializations,
      :procedure_id,
      :integer
    ScItemSpecializationProcedureSpecialization.reset_column_information
    ScItemSpecializationProcedureSpecialization.all.each do |sisps|
      procedure_specialization =
        ProcedureSpecialization.find(sisps.procedure_specialization_id)
      sisps.update_attributes!(
        procedure_id: procedure_specialization.procedure_id
      )
    end
    remove_column :sc_item_specialization_procedure_specializations,
      :procedure_specialization_id
    rename_table :sc_item_specialization_procedure_specializations,
      :sc_item_specialization_procedures

    def filepath(filename)
      Rails.root.join("app", "models", filename)
    end

    sisps_file = filepath("sc_item_specialization_procedure_specialization.rb")
    sisps_file_content = File.read(sisps_file)
    File.open(sisps_file, "w") do |file|
      new_sisps_file_content = sisps_file_content.gsub(
        "ScItemSpecializationProcedureSpecialization",
        "ScItemSpecializationProcedure"
      )
      file.write(new_sisps_file_content)
    end
    File.rename(sisps_file, filepath("sc_item_specialization_procedure.rb"))

    add_index :sc_item_specialization_procedures,
      ["procedure_id", "sc_item_specialization_id"],
      name: "index_sc_item_spec_procedure_on_procedure_and_sc_item_spec"
    add_index :sc_item_specialization_procedures, "procedure_id"
  end
end
