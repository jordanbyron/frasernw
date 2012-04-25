class City < ActiveRecord::Base
  attr_accessible :name, :province_id
  has_paper_trail
  
  belongs_to :province
  has_many :addresses
  has_many :locations, :through => :addresses
  
  has_many :direct_offices, :through => :locations, :source => :locatable, :source_type => "Office"
  
  has_many :clinics, :through => :locations, :source => :locatable, :source_type => "Clinic"
  has_many :locations_in_clinics, :through => :clinics, :source => :locations_in, :class_name => "Location"
  has_many :offices_in_clinics, :through => :locations_in_clinics, :source => :locatable, :source_type => "Office"
  
  has_many :hospitals, :through => :locations, :source => :locatable, :source_type => "Hospital"
  has_many :locations_in_hospitals, :through => :hospitals, :source => :locations_in, :class_name => "Location"
  has_many :offices_in_hospitals, :through => :locations_in_hospitals, :source => :locatable, :source_type => "Office"
  
  has_many :clinics_in_hospitals, :through => :locations_in_hospitals, :source => :locatable, :source_type => "Clinic"
  has_many :locations_in_clinics_in_hospitals, :through => :clinics_in_hospitals, :source => :locations_in, :class_name => "Location"
  has_many :offices_in_clinics_in_hospitals, :through => :locations_in_clinics_in_hospitals, :source => :locatable, :source_type => "Office"
  
  def offices
    direct_offices + offices_in_clinics + offices_in_hospitals + offices_in_clinics_in_hospitals
  end
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def to_s
    self.name
  end
end
