class ProcedureSpecialization < ActiveRecord::Base
  belongs_to :procedure
  belongs_to :specialization
  
  has_many :capacities, :dependent => :destroy
  has_many :specialists, :through => :capacities
  
  has_many :focuses, :dependent => :destroy
  has_many :clinics, :through => :focuses
  
  has_paper_trail
  has_ancestry
  
  def to_s
    return procedure.to_s
  end
end
