class Language < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail meta: { to_review: false }
  
  has_many :speaks
  has_many :specialists, :through => :speaks
  
  has_many :clinic_speaks
  has_many :clinics, :through => :clinic_speaks
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
end
