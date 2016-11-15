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

  def parents_name_array
    ps_with_parents = procedure_specializations.reject{ |ps| ps.parent.blank? }
    if ps_with_parents.count > 0
      ps_with_parents.first.parent.procedure.parents_name_array +
        ps_with_parents.first.parent.procedure.name.uncapitalize_first_letter.split(' ')
    else
      []
    end
  end

  def full_name
    ps_with_parents = procedure_specializations.reject{ |ps| ps.parent.blank? }

    if ps_with_parents.count > 0
      "#{ps_with_parents.first.parent.procedure.full_name} -> "\
        "#{name_relative_to_parents}"
    else
      self.name
    end
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

  def name_relative_to_parents
    # remove any words that also appear in the parents' names
    parents_names = parents_name_array

    self.name.uncapitalize_first_letter.split(' ').
    reject{ |word| parents_names.include? word }.join(' ').capitalize_first_letter
  end

  def has_children?
    result = false
    procedure_specializations.each do |ps|
      result |= ps.has_children?
    end
    return result
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
