class Specialization < ActiveRecord::Base
  attr_accessible :name, :in_progress
  has_paper_trail
  
  has_many :specialist_specializations, :dependent => :destroy
  has_many :specialists, :through => :specialist_specializations
  
  has_many :clinic_specializations, :dependent => :destroy
  has_many :clinics, :through => :clinic_specializations
  
  has_many :procedure_specializations, :dependent => :destroy, :finder_sql => proc { "SELECT DISTINCT ps.*, p.name FROM procedure_specializations ps JOIN procedures p ON ps.procedure_id = p.id WHERE ps.specialization_id = #{self.id} AND ps.mapped = 't' ORDER BY p.name ASC" }
  has_many :procedures, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  
  has_many :focused_procedure_specializations, :dependent => :destroy, :finder_sql => proc { "SELECT DISTINCT ps.*, p.name FROM procedure_specializations ps JOIN procedures p ON ps.procedure_id = p.id WHERE ps.specialization_id = #{self.id} AND ps.mapped = 't' AND ps.classification = #{ProcedureSpecialization::CLASSIFICATION_FOCUSED} ORDER BY p.name ASC" }, :class_name => 'ProcedureSpecialization'
  
  has_many :nonfocused_procedure_specializations, :dependent => :destroy, :finder_sql => proc { "SELECT DISTINCT ps.*, p.name FROM procedure_specializations ps JOIN procedures p ON ps.procedure_id = p.id WHERE ps.specialization_id = #{self.id} AND ps.mapped = 't' AND ps.classification = #{ProcedureSpecialization::CLASSIFICATION_NONFOCUSED} ORDER BY p.name ASC" }, :class_name => 'ProcedureSpecialization'
  
  has_many :assumed_procedure_specializations, :dependent => :destroy, :finder_sql => proc { "SELECT DISTINCT ps.*, p.name FROM procedure_specializations ps JOIN procedures p ON ps.procedure_id = p.id WHERE ps.specialization_id = #{self.id} AND ps.mapped = 't' AND ps.classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED} ORDER BY p.name ASC" }, :class_name => 'ProcedureSpecialization'
  
  default_scope order('name')
  
  def procedure_specializations_arranged
    return procedure_specializations.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't'", :order => "procedures.name")
  end
  
  def focused_procedure_specializations_arranged
    return procedure_specializations.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't' AND procedure_specializations.classification = #{ProcedureSpecialization::CLASSIFICATION_FOCUSED}", :order => "procedures.name")
  end
  
  def nonfocused_procedure_specializations_arranged
    return procedure_specializations.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't' AND procedure_specializations.classification = #{ProcedureSpecialization::CLASSIFICATION_NONFOCUSED}", :order => "procedures.name")
  end
  
  def assumed_procedure_specializations_arranged
    return procedure_specializations.arrange(:joins => "JOIN procedures ON procedure_specializations.procedure_id = procedures.id", :conditions => "procedure_specializations.specialization_id = #{self.id} AND procedure_specializations.mapped = 't' AND procedure_specializations.classification = #{ProcedureSpecialization::CLASSIFICATION_ASSUMED}", :order => "procedures.name")
  end

end

