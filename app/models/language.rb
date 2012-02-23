class Language < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail
  
  has_many :specialist_speaks, :dependent => :destroy
  has_many :specialists, :through => :specialist_speaks
  
  has_many :clinic_speaks, :dependent => :destroy
  has_many :clinics, :through => :clinic_speaks
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
end
