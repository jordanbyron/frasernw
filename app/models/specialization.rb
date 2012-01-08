class Specialization < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail meta: { to_review: false }
  
  has_many :specialist_specializations, :dependent => :destroy
  has_many :specialists, :through => :specialist_specializations
  
  has_many :clinic_specializations, :dependent => :destroy
  has_many :clinics, :through => :clinic_specializations
  
  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }, :finder_sql => proc { "SELECT DISTINCT ps.* FROM procedure_specializations ps JOIN procedures p ON ps.procedure_id = p.id WHERE ps.specialization_id = #{self.id} ORDER BY p.name ASC" }
  has_many :procedures, :through => :procedure_specializations, :uniq => true, :conditions => { "procedure_specializations.mapped" => true }, :order => 'name ASC'
  
  default_scope order('name')

end

