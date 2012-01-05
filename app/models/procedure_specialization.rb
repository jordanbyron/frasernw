class ProcedureSpecialization < ActiveRecord::Base
  belongs_to :procedure
  belongs_to :specialization
  
  has_paper_trail
  has_ancestry
  
  def to_s
    return procedure.to_s
  end
end
