class Office < ActiveRecord::Base
  attr_accessible :location_attributes

  has_one :location, :as => :locatable
  accepts_nested_attributes_for :location
  
  has_many :specialist_offices
  has_many :specialists, :through => :specialist_offices
  
  has_paper_trail
  
  def empty?
    location.blank? || location.empty?
  end
  
  def to_s
    return location.to_s
  end
end
