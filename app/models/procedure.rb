class Procedure < ActiveRecord::Base
  attr_accessible :name, :specialization_level, :parent_id, :specialization_ids, :all_procedure_specializations_attributes
  has_paper_trail
  
  has_many :specialists, :finder_sql => proc { "SELECT DISTINCT s.* FROM specialists s JOIN capacities c ON c.specialist_id = s.id, procedure_specializations ps ON c.procedure_specialization_id = ps.id WHERE ps.procedure_id = #{self.id} ORDER BY s.lastname ASC, s.firstname ASC" }
  
  has_many :clinics, :finder_sql => proc { "SELECT DISTINCT cl.* FROM clinics cl JOIN capacities c ON c.specialist_id = cl.id, procedure_specializations ps ON c.procedure_specialization_id = ps.id WHERE ps.procedure_id = #{self.id} ORDER BY cl.name ASC" }
  
  has_many :all_procedure_specializations, :dependent => :destroy, :class_name => "ProcedureSpecialization"
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :specializations, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  
  accepts_nested_attributes_for :all_procedure_specializations, :allow_destroy => true

  validates_presence_of :name, :on => :save, :message => "can't be blank"
  
  def to_s
    self.name
  end

end
