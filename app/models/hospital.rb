class Hospital < ActiveRecord::Base
  attr_accessible :name, :addresses_attributes
  has_paper_trail meta: { to_review: false }
  
  has_many :privileges, :dependent => :destroy
  has_many :specialists, :through => :privileges
  
  # hospitals can have more than one address
  MAX_ADDRESSES = 2
  has_many :hospital_addresses
  has_many :addresses, :through => :hospital_addresses
  accepts_nested_attributes_for :addresses
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
end
