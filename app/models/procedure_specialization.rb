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
  
  def investigation(specialist_or_clinic)
    if specialist_or_clinic.instance_of? Clinic
      f = Focus.find_by_clinic_id_and_procedure_specialization_id(specialist_or_clinic.id, self.id)
      return f.investigation if f
    else
      c = Capacity.find_by_specialist_id_and_procedure_specialization_id(specialist_or_clinic.id, self.id)
      return c.investigation if c
    end
    return ""
  end
end
