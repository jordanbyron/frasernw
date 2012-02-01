class Hospital < ActiveRecord::Base
  attr_accessible :name, :addresses_attributes
  has_paper_trail meta: { to_review: false }
  
  has_many :privileges, :dependent => :destroy
  has_many :specialists, :through => :privileges
  
  has_many :clinics, :finder_sql => proc { "SELECT DISTINCT c.* FROM clinics c JOIN clinic_addresses ca ON c.id = ca.clinic_id JOIN addresses a ON ca.address_id = a.id WHERE a.hospital_id = #{self.id} ORDER BY c.name ASC" }
  
  has_many :specialist_offices, :finder_sql => proc { "SELECT DISTINCT s.* FROM specialists s JOIN specialist_addresses sa ON s.id = sa.specialist_id JOIN addresses a ON sa.address_id = a.id WHERE a.hospital_id = #{self.id} ORDER BY s.lastname ASC, s.firstname ASC" }, :class_name => "Specialist"
  
  # hospitals can have more than one address
  MAX_ADDRESSES = 2
  has_many :hospital_addresses
  has_many :addresses, :through => :hospital_addresses
  accepts_nested_attributes_for :addresses
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
end
