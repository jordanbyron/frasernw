class Procedure < ActiveRecord::Base
  attr_accessible :name, :parent_id, :specialization_ids, :all_procedure_specializations_attributes
  has_paper_trail :ignore => :saved_token

  has_many :all_procedure_specializations, :dependent => :destroy, :class_name => "ProcedureSpecialization"
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :specializations, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  accepts_nested_attributes_for :all_procedure_specializations, :allow_destroy => true

  has_many :capacities, :through => :procedure_specializations
  has_many :specialists, :through => :capacities

  has_many :focuses, :through => :procedure_specializations
  has_many :clinics, :through => :focuses

  validates_presence_of :name, :on => :save, :message => "can't be blank"

  def to_s
    self.name
  end

  def full_name
    ps_with_parents = procedure_specializations.reject{ |ps| ps.parent.blank? }
    if ps_with_parents.count > 0
      return ps_with_parents.first.parent.procedure.full_name + " " + self.name.uncapitalize_first_letter
    else
      return self.name
    end
  end

  def fully_in_progress_for_divisions(divisions)
    specializations.each do |s|
     return false if (s.specialization_options.for_divisions(divisions).length == 0) || (s.specialization_options.for_divisions(divisions).reject{ |so| so.in_progress }.length != 0)
    end
    return true
  end

  def all_specialists_in_cities(cities)
    #look at this procedure as well as its children to find any specialists
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        if child.assumed_specialist?
          if child.parent.present?
            #only add the specialists that do the parent procedure we are assumed for
            results += child.parent.procedure.all_specialists_for_specialization_in_cities(child.specialization, cities)
          else
            results += ps.specialization.specialists.in_cities(cities)
          end
        else
          Capacity.find_all_by_procedure_specialization_id(child.id).each do |capacity|
            results << capacity.specialist if capacity.specialist.present? && (capacity.specialist.cities & cities).present?
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_clinics_in_cities(cities)
    #look at this procedure as well as its children to find any clinics
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        if child.assumed_clinic?
          if child.parent.present?
            #only add the clinics that do the parent procedure we are assumed for
            results += child.parent.procedure.all_clinics_for_specialization_in_cities(child.specialization, cities)
          else
            results += ps.specialization.clinics.in_cities(cities)
          end
        else
          Focus.find_all_by_procedure_specialization_id(child.id).each do |focus|
            results << focus.clinic if focus.clinic.present? && (focus.clinic.cities & cities)
          end
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_specialists_for_specialization_in_cities(specialization, cities)
    #look at this procedure as well as its children to find any specialists
    results = []
    ps = ProcedureSpecialization.find_by_specialization_id_and_procedure_id(specialization.id, self.id)
    if ps.assumed_specialist?
      results += ps.specialization.specialists.in_cities(cities)
    else
      ps.subtree.each do |child|
        Capacity.find_all_by_procedure_specialization_id(child.id).each do |capacity|
          results << capacity.specialist if capacity.specialist.present? && (capacity.specialist.cities & cities).present?
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def all_clinics_for_specialization_in_cities(specialization, cities)
    #look at this procedure as well as its children to find any clinics
    results = []
    ps = ProcedureSpecialization.find_by_specialization_id_and_procedure_id(specialization.id, self.id)
    if ps.assumed_clinic?
      results += ps.specialization.clinics.in_cities(cities)
    else
      ps.subtree.each do |child|
        Focus.find_all_by_procedure_specialization_id(child.id).each do |focus|
          results << focus.clinic if focus.clinic.present? && (focus.clinic.cities & cities).present?
        end
      end
    end
    results.uniq!
    return (results ? results.compact : [])
  end

  def empty?
    return ((all_specialists_in_cities(City.all).length == 0) and (all_clinics_in_cities(City.all).length == 0))
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
        result << child.procedure.children if ps.procedure != self #recursive
      end
    end
    return result.flatten.uniq
  end

  def focused_children
    result = []
    procedure_specializations.focused.each do |ps|
      ps.children.each do |child|
        result << child.procedure
        result << child.procedure.focused_children if ps.procedure != self #recursive
      end
    end
    return result.flatten.uniq
  end

  def non_focused_children
    result = []
    procedure_specializations.non_focused.each do |ps|
      ps.children.each do |child|
        result << child.procedure
        result << child.procedure.non_focused_children if ps.procedure != self #recursive
      end
    end
    return result.flatten.uniq
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end
end
