class Office < ActiveRecord::Base
  attr_accessible :location_attributes

  has_one :location, :as => :locatable
  accepts_nested_attributes_for :location
  
  has_many :specialist_offices, :dependent => :destroy
  has_many :specialists, :through => :specialist_offices
  has_many :user_controls_specialist_offices, :through => :specialist_offices
  has_many :controlling_users, :through => :user_controls_specialist_offices, :source => :user, :class_name => "User"
  
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
    return nil if l.blank?
    return l.city
  end
  
  def divisions
    return city.present? ? city.divisions : []
  end
  
  def short_address
    l = location
    return "" if l.blank?
    return l.short_address
  end
  
  def full_address
    l = location
    return "" if l.blank?
    return l.full_address
  end
  
  def to_s
    return location.to_s
  end
end
