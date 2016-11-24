class Procedure < ActiveRecord::Base
  attr_accessible :name,
    :parent_id,
    :specialization_ids,
    :procedure_specializations_attributes,
    :specialists_specify_wait_times,
    :clinics_specify_wait_times

  include PaperTrailable

  has_many :procedure_specializations,
    dependent: :destroy
  has_many :specializations,
    through: :procedure_specializations
  accepts_nested_attributes_for :procedure_specializations, allow_destroy: true

  has_many :clinic_procedures, dependent: :destroy
  has_many :clinics, through: :clinic_procedures

  has_many :specialist_procedures, dependent: :destroy
  has_many :specialists, through: :specialist_procedures

  has_many :sc_item_procedures, dependent: :destroy
  has_many :sc_items, through: :sc_item_procedures

  validates_presence_of :name, on: :save, message: "can't be blank"

  def to_s
    self.name
  end

  def form_procedure_specializations
    all_procedure_specializations.
      select(&:specialization_present?).
      sort_by(&:specialization_name)
  end

  def parent
    @parent ||=
      procedure_specializations.
        map(&:parent).
        compact.
        first.
        try(:procedure)
  end

  def full_name
    ancestors.
      map(&:name_relative_to_parents).
      push(name_relative_to_parents).
      join(" -> ")
  end

  def ancestor_ids
    if procedure_specializations.any?
      procedure_specializations.
        first.
        ancestors.
        map(&:procedure_id)
    else
      []
    end
  end

  def names
    name.
      uncapitalize_first_letter.
      split(' ')
  end

  def ancestors
    if parent.nil?
      []
    else
      parent.ancestors.unshift(parent)
    end
  end

  def name_relative_to_parents
    ancestor_names = ancestors.map(&:names).flatten

    names.
      reject{ |name| ancestor_names.include?(name) }.
      join(' ').
      capitalize_first_letter
  end

  def children
    result = []
    procedure_specializations.each do |ps|
      ps.children.each do |child|
        result << child.procedure
        result << child.procedure.children if ps.procedure != self
      end
    end
    return result.flatten.uniq
  end

  def focused_children
    result = []
    procedure_specializations.focused.each do |ps|
      ps.children.each do |child|
        result << child.procedure
        result << child.procedure.focused_children if ps.procedure != self
      end
    end
    return result.flatten.uniq
  end

  def non_focused_children
    result = []
    procedure_specializations.non_focused.each do |ps|
      ps.children.each do |child|
        result << child.procedure
        result << child.procedure.non_focused_children if ps.procedure != self
      end
    end
    return result.flatten.uniq
  end

  def linked_items
    specialists + clinics + sc_items
  end
end
