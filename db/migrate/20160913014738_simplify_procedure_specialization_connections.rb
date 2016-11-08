class SimplifyProcedureSpecializationConnections < ActiveRecord::Migration
  def change
    rename_column :specialists, :waittime_mask, :consultation_wait_time_key
    rename_column :clinics, :waittime_mask, :consultation_wait_time_key

    rename_column :specialists, :lagtime_mask, :booking_wait_time_key
    rename_column :clinics, :lagtime_mask, :booking_wait_time_key

    add_column :procedures,
      :specialists_specify_wait_times,
      :boolean,
      default: false
    add_column :procedures,
      :clinics_specify_wait_times,
      :boolean,
      default: false

    add_column :procedure_specializations, :assumed_for_specialists, :boolean
    add_column :procedure_specializations, :assumed_for_clinics, :boolean

    add_column :procedure_specializations, :focused_for_specialists, :boolean
    add_column :procedure_specializations, :focused_for_clinics, :boolean

    rename_table :capacities, :specialist_procedures
    rename_column :specialist_procedures, :waittime_mask, :consultation_wait_time_key
    rename_column :specialist_procedures, :lagtime_mask, :booking_wait_time_key
    add_column :specialist_procedures, :procedure_id, :integer
    add_index :specialist_procedures, :procedure_id

    rename_table :focuses, :clinic_procedures
    rename_column :clinic_procedures, :waittime_mask, :consultation_wait_time_key
    rename_column :clinic_procedures, :lagtime_mask, :booking_wait_time_key
    add_column :clinic_procedures, :procedure_id, :integer
    add_index :clinic_procedures, :procedure_id

    rename_table :sc_item_specialization_procedure_specializations, :sc_item_procedures
    add_column :sc_item_procedures, :procedure_id, :integer
    add_column :sc_item_procedures, :sc_item_id, :integer
    add_index :sc_item_procedures, :procedure_id

    Procedure.reset_column_information
    ProcedureSpecialization.reset_column_information
    SpecialistProcedure.reset_column_information
    ClinicProcedure.reset_column_information
    ScItemProcedure.reset_column_information

    ProcedureSpecialization.
      all.
      each do |procedure_specialization|
        procedure_specialization.procedure.update_attributes!(
          specialists_specify_wait_times: procedure_specialization.specialist_wait_time
        )
      end
    ProcedureSpecialization.
      all.
      each do |procedure_specialization|
        procedure_specialization.procedure.update_attributes!(
          clinics_specify_wait_times: procedure_specialization.clinic_wait_time
        )
      end

    ProcedureSpecialization.all.each do |ps|
      ps.update_attributes!(
        assumed_for_specialists: (
          ps.classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH ||
            ps.classification === ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST
        ),
        assumed_for_clinics: (
          ps.classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH ||
            ps.classification === ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC
        ),
        focused_for_specialists: (
          ps.classification == ProcedureSpecialization::CLASSIFICATION_FOCUSED ||
            ps.classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC
        ),
        focused_for_clinics: (
          ps.classification == ProcedureSpecialization::CLASSIFICATION_FOCUSED ||
            ps.classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST
        )
      )
    end

    SpecialistProcedure.where(procedure_specialization_id: nil).destroy_all
    SpecialistProcedure.where(specialist_id: nil).destroy_all
    SpecialistProcedure.all.each do |specialist_procedure|
      specialist_procedure.update_attributes!(
        procedure_id: specialist_procedure.procedure_specialization.procedure_id
      )
    end
    keeping_specialist_procedures = SpecialistProcedure.all.uniq do |specialist_procedure|
      [ specialist_procedure.specialist_id, specialist_procedure.procedure_id ]
    end.map(&:id)
    SpecialistProcedure.
      where("specialist_procedures.id NOT IN (?)", keeping_specialist_procedures).
      map(&:destroy)

    ClinicProcedure.where(procedure_specialization_id: nil).destroy_all
    ClinicProcedure.where(clinic_id: nil).destroy_all
    ClinicProcedure.all.each do |clinic_procedure|
      clinic_procedure.update_attributes!(
        procedure_id: clinic_procedure.procedure_specialization.procedure_id
      )
    end
    keeping_clinic_procedures = ClinicProcedure.all.uniq do |clinic_procedure|
      [ clinic_procedure.clinic_id, clinic_procedure.procedure_id ]
    end.map(&:id)
    ClinicProcedure.
      where("clinic_procedures.id NOT IN (?)", keeping_clinic_procedures).
      map(&:destroy)

    ScItemProcedure.where(procedure_specialization_id: nil).destroy_all
    ScItemProcedure.where(sc_item_specialization_id: nil).destroy_all
    ScItemProcedure.select do |sc_item_procedure|
      sc_item_procedure.procedure_specialization.nil? ||
        sc_item_procedure.sc_item_specialization.nil?
    end.map(&:destroy)
    ScItemProcedure.all.each do |sc_item_procedure|
      sc_item_procedure.update_attributes!(
        procedure_id: sc_item_procedure.procedure_specialization.procedure_id,
        sc_item_id: sc_item_procedure.sc_item_specialization.sc_item_id
      )
    end
    keeping_sc_item_procedures = ScItemProcedure.all.uniq do |sc_item_procedure|
      [ sc_item_procedure.sc_item_id, sc_item_procedure.procedure_id ]
    end.map(&:id)
    ScItemProcedure.
      where("sc_item_procedures.id NOT IN (?)", keeping_sc_item_procedures).
      map(&:destroy)
  end
end
