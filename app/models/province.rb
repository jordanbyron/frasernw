class Province < ActiveRecord::Base
  attr_accessible :name, :abbreviation, :symbol
  include PaperTrailable

  has_many :cities, :order => "name ASC"
  has_many :addresses, :through => :cities

  default_scope order('provinces.name')

  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :abbreviation, :on => :create, :message => "can't be blank"
  validates_presence_of :symbol, :on => :create, :message => "can't be blank"

  def to_s
    self.name
  end
end
