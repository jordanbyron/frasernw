class Office < ActiveRecord::Base
  attr_accessible :location_attributes

  has_one :location, :as => :locatable
  accepts_nested_attributes_for :location
  
  has_many :specialist_offices
  has_many :specialists, :through => :specialist_offices
  
  has_many :specializations, :through => :specialists
  has_many :procedures, :through => :specialists
  has_many :hospitals, :through => :specialists
  has_many :languages, :through => :specialists
  
  has_paper_trail
  
  def empty?
    location.blank? || location.empty?
  end
  
  def num_specialists
    specialists.count
  end
  
  def city
    l = location
    return "" if l.blank?
    return l.city
  end
  
  def city_id
    l = location
    return l.present? ? l.city_id : nil
  end
  
  def short_address
    l = location
    return "" if l.blank?
    return l.short_address
  end
  
  def to_s
    return location.to_s
  end
end
