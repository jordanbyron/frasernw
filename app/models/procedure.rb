class Procedure < ActiveRecord::Base
  attr_accessible :name, :parent_id, :specialization_ids, :all_procedure_specializations_attributes

  include PaperTrailable

  has_many :all_procedure_specializations, :dependent => :destroy, :class_name => "ProcedureSpecialization"
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :specializations, :through => :procedure_specializations, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  accepts_nested_attributes_for :all_procedure_specializations, :allow_destroy => true

  has_many :capacities, :through => :procedure_specializations
  has_many :specialists, :through => :capacities

  has_many :focuses, :through => :procedure_specializations
  has_many :clinics, :through => :focuses

  validates_presence_of :name, :on => :save, :message => "can't be blank"

  def to_s
    self.name
  end

  def parents_name_array
    ps_with_parents = procedure_specializations.reject{ |ps| ps.parent.blank? }
    if ps_with_parents.count > 0
      return ps_with_parents.first.parent.procedure.parents_name_array + ps_with_parents.first.parent.procedure.name.uncapitalize_first_letter.split(' ')
    else
      return []
    end
  end

  def full_name
    ps_with_parents = procedure_specializations.reject{ |ps| ps.parent.blank? }

    if ps_with_parents.count > 0
      "#{ps_with_parents.first.parent.procedure.full_name} #{name_relative_to_parents.uncapitalize_first_letter}"
    else
      self.name
    end
  end

  def name_relative_to_parents
    #remove any words that also appear in the parents' names
    parents_names = parents_name_array
    self.name.uncapitalize_first_letter.split(' ').reject{ |word| parents_names.include? word }.join(' ').capitalize_first_letter
  end

  def fully_in_progress_for_divisions(divisions)
    specializations.each do |s|
     return false if (s.specialization_options.for_divisions(divisions).length == 0) || (s.specialization_options.for_divisions(divisions).reject{ |so| so.in_progress }.length != 0)
    end
    return true
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

  def specialist_wait_time
    procedure_specializations.first.try(:specialist_wait_time) || false
  end

  def clinic_wait_time
    procedure_specializations.first.try(:clinic_wait_time) || false
  end
end
