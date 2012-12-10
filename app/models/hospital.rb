class Hospital < ActiveRecord::Base
  attr_accessible :name, :phone, :phone_extension, :fax, :location_attributes, :address_attributes
  has_paper_trail :ignore => :saved_token
  
  has_many :privileges, :dependent => :destroy
  has_many :specialists, :through => :privileges
  
  has_many :locations_in, :foreign_key => :hospital_in_id, :class_name => "Location"
  
  has_many :direct_offices_in, :through => :locations_in, :source => :locatable, :source_type => "Office"
  
  has_many :clinics_in, :through => :locations_in, :source => :locatable, :source_type => "Clinic"
  
  has_many :locations_in_clinics_in, :through => :clinics_in, :source => :locations_in, :class_name => "Location"
  has_many :offices_in_clinics_in, :through => :locations_in_clinics_in, :source => :locatable, :source_type => "Office"
  
  def offices_in
    direct_offices_in + offices_in_clinics_in
  end
  
  #hospitals have an address
  has_one :location, :as => :locatable
  has_one :address, :through => :location
  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :address
  
  def self.in_cities(cities)
    city_ids = cities.map{ |city| city.id }
    joins('INNER JOIN "locations" ON "hospitals".id = "locations".locatable_id INNER JOIN "addresses" ON "locations".address_id = "addresses".id').where('"locations".locatable_type = (?) AND "addresses".city_id in (?)', "Hospital", city_ids)
  end
  
  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end
  
  default_scope order('hospitals.name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  def phone_and_fax
    return "#{phone} ext. #{phone_extension}, Fax: #{fax}" if phone.present? && phone_extension.present? && fax.present?
    return "#{phone} ext. #{phone_extension}" if phone.present? && phone_extension.present?
    return "#{phone}, Fax: #{fax}" if phone.present? && fax.present?
    return "ext. #{phone_extension}, Fax: #{fax}" if phone_extension.present? && fax.present?
    return "#{phone}" if phone.present?
    return "Fax: #{fax}" if fax.present?
    return "ext. #{phone_extension}" if phone_extension.present?
    return ""
  end
  
  def city
    l = location
    return nil if l.blank?
    #hospitals can't be in anything, no need to resolve_address
    a = location.address
    return nil if a.blank? || a.city.blank?
    return a.city
  end
  
  def divisions
    return city.present? ? city.divisions : []
  end
  
  def resolved_address
    return location.resolved_address if location
    return nil
  end
  
  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end
end
