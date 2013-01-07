class ProcedureSpecialization < ActiveRecord::Base
   
  CLASSIFICATION_FOCUSED    = 1
  CLASSIFICATION_NONFOCUSED = 2
  CLASSIFICATION_ASSUMED    = 3
  
  CLASSIFICATION_HASH = { 
    CLASSIFICATION_FOCUSED => "Focused", 
    CLASSIFICATION_NONFOCUSED => "Non-Focused", 
    CLASSIFICATION_ASSUMED => "Assumed"
  }
  
  belongs_to :procedure
  belongs_to :specialization
  scope :focused, where("classification = #{ProcedureSpecialization::CLASSIFICATION_FOCUSED}")
  scope :non_focused, where("classification = #{ProcedureSpecialization::CLASSIFICATION_NONFOCUSED}")
  scope :assumed, where("classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED}")
  scope :non_assumed, where("classification != #{ProcedureSpecialization::CLASSIFICATION_ASSUMED}")
  
  has_many :capacities, :dependent => :destroy
  has_many :specialists, :through => :capacities
  
  has_many :focuses, :dependent => :destroy
  has_many :clinics, :through => :focuses
  
  has_paper_trail
  has_ancestry
  
  def classification_text
    ProcedureSpecialization::CLASSIFICATION_HASH[classification]
  end
  
  def focused?
    classification == ProcedureSpecialization::CLASSIFICATION_FOCUSED
  end
  
  def nonfocused?
    classification == ProcedureSpecialization::CLASSIFICATION_NONFOCUSED
  end
  
  def assumed?
    classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED
  end
  
  def self.specialist_wait_time
    where('procedure_specializations.specialist_wait_time = (?)', true)
  end
  
  def self.clinic_wait_time
    where('procedure_specializations.clinic_wait_time = (?)', true)
  end
  
  def to_s
    procedure.to_s
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
