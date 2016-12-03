class ProcedureSpecialization < ActiveRecord::Base

  attr_accessible :classification,
    :parent_id,
    :specialist_wait_time,
    :clinic_wait_time,
    :specialization_id

  CLASSIFICATION_FOCUSED              = 1
  CLASSIFICATION_NONFOCUSED           = 2
  CLASSIFICATION_ASSUMED_SPECIALIST   = 3
  CLASSIFICATION_ASSUMED_CLINIC       = 4
  CLASSIFICATION_ASSUMED_BOTH         = 5

  CLASSIFICATION_HASH = {
    CLASSIFICATION_FOCUSED => "Focused",
    CLASSIFICATION_NONFOCUSED => "Non-Focused",
    CLASSIFICATION_ASSUMED_SPECIALIST => "Assumed for Specialists",
    CLASSIFICATION_ASSUMED_CLINIC => "Assumed for Clinics",
    CLASSIFICATION_ASSUMED_BOTH => "Assumed for Specialists and Clinics"
  }

  belongs_to :procedure
  belongs_to :specialization
  scope :focused,
    -> { where(
    "classification = #{ProcedureSpecialization::CLASSIFICATION_FOCUSED}"
    ) }
  scope :non_focused,
    -> { where(
    "classification = #{ProcedureSpecialization::CLASSIFICATION_NONFOCUSED}"
    ) }
  scope :assumed_specialist,
    -> { where(
    "classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST} "\
      "OR classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH}"
    ) }
  scope :assumed_clinic,
    -> { where(
    "classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC} "\
      "OR classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH}"
    ) }
  scope :non_assumed,
    -> { where(
    "classification = #{ProcedureSpecialization::CLASSIFICATION_FOCUSED} "\
      "OR classification = #{ProcedureSpecialization::CLASSIFICATION_NONFOCUSED}"
    ) }
  scope :classification,
    -> (classification){ where(
    "classification = (?)", classification
    ) }
  scope :has_procedure, -> { joins(:procedure) }

  has_many :capacities, dependent: :destroy
  has_many :specialists, through: :capacities

  has_many :focuses, dependent: :destroy
  has_many :clinics, through: :focuses

  include PaperTrailable
  has_ancestry

  def self.for_specialization(specialization)
    where('procedure_specializations.specialization_id = (?)', specialization.id)
  end

  def matches_ancestry?(ancestry)
    if ancestry.is_a? String
      ancestry = ancestry.split(" > ")
    end

    if ancestry.length == 1
      procedure.name == ancestry.pop
    else
      procedure.name == ancestry.pop &&
        safe_parent.present? &&
        safe_parent.matches_ancestry?(ancestry)
    end
  end

  def ancestor_procedure_ids(force = false)
    ancestors.map(&:procedure).map(&:id)
  end

  def safe_parent
    if ancestry.nil?
      NullProcedureSpecialization.new
    else
      ProcedureSpecialization.where(id: ancestry).first ||
        NullProcedureSpecialization.new
    end
  end

  def classification_text
    ProcedureSpecialization::CLASSIFICATION_HASH[classification]
  end

  def focused?
    classification == ProcedureSpecialization::CLASSIFICATION_FOCUSED
  end

  def nonfocused?
    classification == ProcedureSpecialization::CLASSIFICATION_NONFOCUSED
  end

  def assumed_specialist?
    classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_SPECIALIST ||
      classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH
  end

  def assumed_clinic?
    classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_CLINIC ||
      classification == ProcedureSpecialization::CLASSIFICATION_ASSUMED_BOTH
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

  def with_ancestor_names
    if parent.present?
      "#{parent.with_ancestor_names} #{procedure.name_relative_to_parents.downcase}"
    else
      procedure.try(:name)
    end
  end

  def investigation(specialist_or_clinic)
    if specialist_or_clinic.instance_of? Clinic
      f = Focus.find_by(
        clinic_id: specialist_or_clinic.id,
        procedure_specialization_id: self.id
      )
      return f.investigation if f
    else
      c = Capacity.find_by(
        specialist_id: specialist_or_clinic.id,
        procedure_specialization_id: self.id
      )
      return c.investigation if c
    end
    return ""
  end

  def specialization_name
    specialization.name
  end

  def specialization_present?
    specialization.present?
  end
end
