class RemoveUnmappedProcedureSpecializations < ActiveRecord::Migration
  def up
    ProcedureSpecialization.where(mapped: false).delete_all

    Capacity.
      includes(:procedure_specialization).
      select{|capacity| capacity.procedure_specialization.nil? }.
      map(&:delete)

    Focus.
      includes(:procedure_specialization).
      all.select{|focus| focus.procedure_specialization.nil? }.
      map(&:delete)

    remove_column :procedure_specializations, :mapped
  end
end
