class DestroyBadRecords < ActiveRecord::Migration
  def change
    Focus.where('clinic_id > 1004').each{ |f| f.delete }

    procedure_specialization_ids = ProcedureSpecialization.all.map(&:id)
    ScItemSpecializationProcedureSpecialization.all.reject do |sisps|
      procedure_specialization_ids.include?(sisps.procedure_specialization_id)
    end.each{ |sisps| sisps.delete }
  end
end
