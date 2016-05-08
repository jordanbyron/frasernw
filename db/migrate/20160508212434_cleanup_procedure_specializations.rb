class CleanupProcedureSpecializations < ActiveRecord::Migration
  def up
    ProcedureSpecialization.where(specialization_id: nil).destroy_all
  end

  def down
  end
end
