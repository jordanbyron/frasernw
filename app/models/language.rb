class Language < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail :ignore => :saved_token
  
  has_many :specialist_speaks, :dependent => :destroy
  has_many :specialists, :through => :specialist_speaks
  
  has_many :clinic_speaks, :dependent => :destroy
  has_many :clinics, :through => :clinic_speaks
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
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
