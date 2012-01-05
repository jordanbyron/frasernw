class Procedure < ActiveRecord::Base
  attr_accessible :name, :specialization_id, :specialization_level, :parent_id, :specialization_ids, :all_procedure_specializations_attributes
  has_paper_trail
  has_ancestry

  has_many :capacities, :dependent => :destroy
  has_many :specialists, :through => :capacities
  
  has_many :focuses, :dependent => :destroy
  has_many :clinics, :through => :focuses
  
  has_many :all_procedure_specializations, :dependent => :destroy, :class_name => "ProcedureSpecialization"
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :specializations, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  
  accepts_nested_attributes_for :all_procedure_specializations, :allow_destroy => true

  validates_presence_of :name, :on => :save, :message => "can't be blank"
  
  def to_s
    self.name
  end

end
