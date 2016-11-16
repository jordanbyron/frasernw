class ProcedureSpecialization < ActiveRecord::Base

  attr_accessible :classification,
    :parent_id,
    :specialization_id,
    :specialists_presentation_key,
    :clinics_presentation_key

  # TODO remove:

  CLASSIFICATION_FOCUSED              = 1
  CLASSIFICATION_NONFOCUSED           = 2
  CLASSIFICATION_ASSUMED_SPECIALIST   = 3
  CLASSIFICATION_ASSUMED_CLINIC       = 4
  CLASSIFICATION_ASSUMED_BOTH         = 5

  #

  PRESENTATION_OPTIONS = StrictHash.new(
    1 => :assumed,
    2 => :focused,
    3 => :non_focused
  )

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
    -> (klass) { where(
      "#{"#{klass.to_s.tableize}_presentation_key"} != (?)",
      PRESENTATION_OPTIONS.key(:assumed))
    }
  scope :classification,
    -> (classification){ where(
    "classification = (?)", classification
    ) }
  scope :has_procedure, -> { joins(:procedure) }

  include PaperTrailable
  has_ancestry

  after_commit :flush_cached_find

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  def flush_cached_find
    Rails.cache.delete([self.class.name, id])
  end

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
        procedure_id: self.procedure_id
      )
      return f.investigation if f
    else
      c = Capacity.find_by(
        specialist_id: specialist_or_clinic.id,
        procedure_id: self.procedure_id
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

  def procedure_name
    procedure.name
  end

  [
    :assumed,
    :focused,
    :non_focused
  ].each do |config_option|
    method_name = "#{config_option}_for?"

    define_method method_name do |arg|
      case arg
      when Symbol
        send("#{arg}_presentation_key") ==
          PRESENTATION_OPTIONS.key(config_option)
      when ScItem
        false
      when Specialist, Clinic
        send(method_name, arg.class.to_s.tableize.to_sym) &&
          arg.specializations.include?(specialization)
      end
    end
  end
end
