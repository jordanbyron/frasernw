class Procedure < ActiveRecord::Base
  attr_accessible :name,
    :parent_id,
    :specialization_ids,
    :procedure_specializations_attributes,
    :specialists_specify_wait_times,
    :clinics_specify_wait_times

  include PaperTrailable

  has_many :all_procedure_specializations,
    dependent: :destroy,
    class_name: "ProcedureSpecialization"
  has_many :procedure_specializations,
    dependent: :destroy
  has_many :specializations,
    -> { order('specializations.name ASC') },
    through: :procedure_specializations
  accepts_nested_attributes_for :procedure_specializations, allow_destroy: true

  has_many :capacities, dependent: :destroy
  has_many :specialists, through: :capacities

  has_many :focuses, dependent: :destroy
  has_many :clinics, through: :focuses

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
      "#{ps_with_parents.first.parent.procedure.full_name} "\
        "#{name_relative_to_parents.uncapitalize_first_letter}"
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

  def all_specialists_in_cities(cities)
    # look at this procedure as well as its children to find any specialists
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        if child.assumed_specialist?
          if child.parent.present?
            # add only the specialists that do the parent procedure we are assumed for
            results += child.parent.procedure.
              all_specialists_for_specialization_in_cities(child.specialization, cities)
          else
            results += ps.specialization.specialists.in_cities_cached(cities)
          end
        else
          Capacity.where(procedure_id: child.procedure_id).each do |capacity|
            if (
              capacity.specialist.present? &&
              (capacity.specialist.cities & cities).present?
            )
              results << capacity.specialist
            end
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_clinics_in_cities(cities)
    # look at this procedure as well as its children to find any clinics
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        if child.assumed_clinic?
          if child.parent.present?
            # add only the clinics that do the parent procedure we are assumed for
            results += child.parent.procedure.
              all_clinics_for_specialization_in_cities(child.specialization, cities)
          else
            results += ps.specialization.clinics.in_cities(cities)
          end
        else
          Focus.where(procedure_id: child.procedure_id).each do |focus|
            if focus.clinic.present? && (focus.clinic.cities & cities)
              results << focus.clinic
            end
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_specialists_for_specialization_in_cities(specialization, cities)
    # look at this procedure as well as its children to find any specialists
    results = []
    ps = ProcedureSpecialization.
      find_by(specialization_id: specialization.id, procedure_id: self.id)
    if ps.assumed_specialist?
      results += ps.specialization.specialists.in_cities_cached(cities)
    else
      ps.subtree.each do |child|
        Capacity.where(procedure_id: child.procedure_id).each do |capacity|
          if (
            capacity.specialist.present? &&
            (capacity.specialist.cities & cities).present?
          )
            results << capacity.specialist
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_clinics_for_specialization_in_cities(specialization, cities)
    # look at this procedure as well as its children to find any clinics
    results = []
    ps = ProcedureSpecialization.
      find_by(specialization_id: specialization.id, procedure_id: self.id)
    if ps.assumed_clinic?
      results += ps.specialization.clinics.in_cities(cities)
    else
      ps.subtree.each do |child|
        Focus.where(procedure_id: child.procedure_id).each do |focus|
          if focus.clinic.present? && (focus.clinic.cities & cities).present?
            results << focus.clinic
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def empty?
    return (
      (all_specialists_in_cities(City.all).length == 0) and
      (all_clinics_in_cities(City.all).length == 0)
    )
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

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16))
      return self.saved_token
    end
  end
end
