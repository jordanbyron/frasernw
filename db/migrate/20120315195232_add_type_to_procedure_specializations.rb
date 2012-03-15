class AddTypeToProcedureSpecializations < ActiveRecord::Migration
  def change
    add_column :procedure_specializations, :classification, :integer
    
    ProcedureSpecialization.all.each do |ps|
      p = ps.procedure
      if p.blank?
        ps.classification = ProcedureSpecialization::CLASSIFICATION_FOCUSED
      elsif p.specialization_level
        ps.classification = ProcedureSpecialization::CLASSIFICATION_FOCUSED
      else
        ps.classification = ProcedureSpecialization::CLASSIFICATION_NONFOCUSED
      end
      ps.save
    end
  end
end
