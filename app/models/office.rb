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
  
  def self.in_cities(c)
    city_ids = c.map{ |city| city.id }
    direct = joins('INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "addresses" AS "direct_address" ON "direct_location".address_id = "direct_address".id').where('"direct_location".locatable_type = (?) AND "direct_address".city_id in (?) AND "direct_location".hospital_in_id IS NULL AND "direct_location".clinic_in_id IS NULL', "Office", city_ids)
  
    in_hospital = joins('INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "hospitals" ON "hospitals".id = "direct_location".hospital_in_id INNER JOIN "locations" AS "hospital_in_location" ON "hospitals".id = "hospital_in_location".locatable_id INNER JOIN "addresses" AS "hospital_address" ON "hospital_in_location".address_id = "hospital_address".id').where('"direct_location".locatable_type = (?) AND "hospital_in_location".locatable_type = (?) AND "hospital_address".city_id in (?)', "Office", "Hospital", city_ids)
  
    in_clinic = joins('INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "clinics" ON "clinics".id = "direct_location".clinic_in_id INNER JOIN "locations" AS "clinic_in_location" ON "clinics".id = "clinic_in_location".locatable_id INNER JOIN "addresses" AS "clinic_address" ON "clinic_in_location".address_id = "clinic_address".id').where('"direct_location".locatable_type = (?) AND "direct_location".hospital_in_id IS NULL AND "clinic_in_location".locatable_type = (?) AND "clinic_in_location".hospital_in_id IS NULL AND "clinic_address".city_id in (?)', "Office", "Clinic", city_ids)
  
    in_clinic_in_hospital = joins('INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "clinics" ON "clinics".id = "direct_location".clinic_in_id INNER JOIN "locations" AS "clinic_in_location" ON "clinics".id = "clinic_in_location".locatable_id INNER JOIN "hospitals" ON "clinic_in_location".hospital_in_id = "hospitals".id INNER JOIN "locations" AS "hospital_in_location" ON "hospitals".id = "hospital_in_location".locatable_id INNER JOIN "addresses" AS "hospital_address" ON "hospital_in_location".address_id = "hospital_address".id').where('"direct_location".locatable_type = (?) AND "direct_location".hospital_in_id IS NULL AND "clinic_in_location".locatable_type = (?) AND "hospital_in_location".locatable_type = (?) AND "hospital_address".city_id in (?)', "Office", "Clinic", "Hospital", city_ids)
  
    (direct + in_hospital + in_clinic + in_clinic_in_hospital).uniq
  end
  
  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end
  
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
