class Procedure < ActiveRecord::Base
  attr_accessible :name, :specialization_level, :parent_id, :specialization_ids, :all_procedure_specializations_attributes
  has_paper_trail :ignore => :saved_token
  
  has_many :specialists, :finder_sql => proc { "SELECT DISTINCT s.* FROM specialists s JOIN capacities c ON c.specialist_id = s.id JOIN procedure_specializations ps ON c.procedure_specialization_id = ps.id JOIN specializations sz ON ps.specialization_id = sz.id WHERE ps.procedure_id = #{self.id} AND sz.in_progress = 'f' ORDER BY s.lastname ASC, s.firstname ASC" }
  
  has_many :specialists_including_in_progress, :finder_sql => proc { "SELECT DISTINCT s.* FROM specialists s JOIN capacities c ON c.specialist_id = s.id JOIN procedure_specializations ps ON c.procedure_specialization_id = ps.id WHERE ps.procedure_id = #{self.id} ORDER BY s.lastname ASC, s.firstname ASC" }, :class_name => "Specialist"
  
  has_many :clinics, :finder_sql => proc { "SELECT DISTINCT cl.* FROM clinics cl JOIN focuses f ON f.clinic_id = cl.id JOIN procedure_specializations ps ON f.procedure_specialization_id = ps.id JOIN specializations sz ON ps.specialization_id = sz.id WHERE ps.procedure_id = #{self.id} AND sz.in_progress = 'f' ORDER BY cl.name ASC" }
  
  has_many :clinics_including_in_progress, :finder_sql => proc { "SELECT DISTINCT cl.* FROM clinics cl JOIN focuses f ON f.clinic_id = cl.id JOIN procedure_specializations ps ON f.procedure_specialization_id = ps.id WHERE ps.procedure_id = #{self.id} ORDER BY cl.name ASC" }, :class_name => "Clinic"
  
  has_many :all_procedure_specializations, :dependent => :destroy, :class_name => "ProcedureSpecialization"
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :specializations, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true, "in_progress" => false }, :order => 'name ASC'
  has_many :specializations_including_in_progress, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC', :source => :specialization, :class_name => "Specialization"
  
  accepts_nested_attributes_for :all_procedure_specializations, :allow_destroy => true

  validates_presence_of :name, :on => :save, :message => "can't be blank"
  
  def to_s
    self.name
  end
  
  def full_name
    if procedure_specializations.first and procedure_specializations.first.parent
      return procedure_specializations.first.parent.procedure.full_name + " " + self.name
    else
      return self.name
    end
  end
  
  def all_specialists
    #look at this procedure as well as its children to find any specialists
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        Capacity.find_all_by_procedure_specialization_id(child.id).each do |capacity|
          results << capacity.specialist
        end
      end
    end
    results.uniq!
    return results.compact if results else []
  end
  
  def all_clinics
    #look at this procedure as well as its children to find any clinics
    results = []
    procedure_specializations.each do |ps|
      ProcedureSpecialization.subtree_of(ps).each do |child|
        Focus.find_all_by_procedure_specialization_id(child.id).each do |focus|
          results << focus.clinic
        end
      end
    end
    results.uniq!
    return results.compact if results else []
  end
  
  def all_specialists_for_specialization(specialization)
    #look at this procedure as well as its children to find any specialists
    results = []
    ProcedureSpecialization.find_by_specialization_id_and_procedure_id(specialization.id, self.id).subtree.each do |child|
      Capacity.find_all_by_procedure_specialization_id(child.id).each do |capacity|
        results << capacity.specialist
      end
    end
    results.uniq!
    return results.compact if results else []
  end
  
  def all_clinics_for_specialization(specialization)
    #look at this procedure as well as its children to find any clinics
    results = []
    ProcedureSpecialization.find_by_specialization_id_and_procedure_id(specialization.id, self.id).subtree.each do |child|
      Focus.find_all_by_procedure_specialization_id(child.id).each do |focus|
        results << focus.clinic
      end
    end
    results.uniq!
    return results.compact if results else []
  end
  
  def empty?
    return ((all_specialists.length == 0) and (all_clinics.length == 0))
  end
  
  def empty_for_specialization?(specialization)
    return ((all_specialists_for_specialization(specialization).length == 0) and (all_clinics_for_specialization(specialization).length == 0))
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
  
  def token
    if self.saved_token
      return self.saved_token
    else
      self.saved_token = SecureRandom.hex(16)
      self.save
      return self.saved_token
    end
  end
end
