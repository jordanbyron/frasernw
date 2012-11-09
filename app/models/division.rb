class Division < ActiveRecord::Base
  
  attr_accessible :name, :city_ids
   
  has_many :division_cities, :dependent => :destroy
  has_many :cities, :through => :division_cities
  
  has_paper_trail
  
  default_scope order('divisions.name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end

end
