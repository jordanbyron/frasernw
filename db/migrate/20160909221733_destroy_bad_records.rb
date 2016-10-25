class DestroyBadRecords < ActiveRecord::Migration
  def change
    Focus.all.select do |focus|
      focus.clinic.nil?
    end.map(&:destroy)

    Capacity.all.select do |capacity|
      capacity.specialist.nil?
    end.map(&:destroy)

    procedure_specialization_ids = ProcedureSpecialization.all.map(&:id)
    ScItemSpecializationProcedure.all.reject do |sisps|
      procedure_specialization_ids.include?(sisps.procedure_specialization_id)
    end.each(&:destroy)
  end
end
