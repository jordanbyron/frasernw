class Specialization < ActiveRecord::Base
  attr_accessible :name, :member_name, :in_progress, :specialization_owner_attributes
  has_paper_trail :ignore => :saved_token
  
  has_many :specialist_specializations, :dependent => :destroy
  has_many :specialists, :through => :specialist_specializations
  
  has_many :clinic_specializations, :dependent => :destroy
  has_many :clinics, :through => :clinic_specializations
  
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "procedure_specializations.mapped" => true }
  has_many :procedures, :through => :procedure_specializations, :order => 'name ASC'
  
  has_many :sc_items_specializations, :dependent => :destroy
  has_many :sc_items, :through => :sc_items_specializations
  
  has_one :specialization_owner, :dependent => :destroy
  accepts_nested_attributes_for :specialization_owner
  has_one :owner, :through => :specialization_owner, :class_name => "User"
  
  default_scope order('specializations.name')
  
  def self.not_in_progress
    where("specializations.in_progress = ?", false)
  end
  
  def procedure_specializations_arranged
    return procedure_specializations.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
  end
  
  def focused_procedure_specializations_arranged
    return procedure_specializations.focused.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
  end
  
  def non_focused_procedure_specializations_arranged
    return procedure_specializations.non_focused.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
  end
  
  def assumed_procedure_specializations_arranged
    return procedure_specializations.assumed.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
  end
  
  def non_assumed_procedure_specializations_arranged
    return procedure_specializations.non_assumed.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
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

