class City < ActiveRecord::Base
  attr_accessible :name, :province_id
  has_paper_trail
  
  belongs_to :province
  has_many :addresses
  has_many :locations, :through => :addresses
  
  default_scope order('cities.name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end
end
