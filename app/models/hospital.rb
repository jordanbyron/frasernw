class Hospital < ActiveRecord::Base
  attr_accessible :name,
    :phone,
    :phone_extension,
    :fax,
    :location_attributes,
    :address_attributes

  validates_presence_of :name, on: :create, message: "can't be blank"

  has_many :privileges, dependent: :destroy
  has_many :specialists, through: :privileges

  has_many :locations_in, foreign_key: :hospital_in_id, class_name: "Location"

  has_many :direct_offices_in,
    through: :locations_in,
    source: :locatable,
    source_type: "Office"

  has_many :clinics_locations_in,
    through: :locations_in,
    source: :locatable,
    source_type: "ClinicLocation"
  has_many :clinics_in,
    through: :clinics_locations_in,
    source: :clinic,
    class_name: "Clinic"

  has_many :locations_in_clinics_in,
    through: :locations_in,
    source: :locations_in,
    foreign_key: :location_in_id,
    class_name: "Location"
  has_many :offices_in_clinics_in,
    through: :locations_in_clinics_in,
    source: :locatable,
    source_type: "Office"

  has_one :location, as: :locatable
  has_one :address, through: :location

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :address

  default_scope { order('hospitals.name') }

  include PaperTrailable

  def self.all_formatted_for_form
    includes_location_data.
      order("name ASC").
      map{ |h| ["#{h.name} - #{h.short_address}", h.id] }
  end

  def self.includes_location_data
    includes(location: { address: :city })
  end

  def self.in_cities(cities)
    city_ids = cities.map{ |city| city.id }
    joins(
      'INNER JOIN "locations" ON "hospitals".id = "locations".locatable_id '\
        'INNER JOIN "addresses" ON "locations".address_id = "addresses".id'
    ).where(
      '"locations".locatable_type = (?) AND "addresses".city_id in (?)',
      "Hospital",
      city_ids
    )
  end

  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end

  def self.all_formatted_for_select
    self.
      includes_location_data.
      map(&:formatted_for_select)
  end

  def offices_in
    direct_offices_in + offices_in_clinics_in
  end


  def phone_and_fax
    if phone.present? && phone_extension.present? && fax.present?
      "#{phone} ext. #{phone_extension}, Fax: #{fax}"
    elsif phone.present? && phone_extension.present?
      "#{phone} ext. #{phone_extension}"
    elsif phone.present? && fax.present?
      "#{phone}, Fax: #{fax}"
    elsif phone_extension.present? && fax.present?
      "ext. #{phone_extension}, Fax: #{fax}"
    elsif phone.present?
      "#{phone}"
    elsif fax.present?
      "Fax: #{fax}"
    elsif phone_extension.present?
      "ext. #{phone_extension}"
    else
      ""
    end
  end

  def city
    l = location
    return nil if l.blank?
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

  def short_address
    return "" if location.blank?
    return location.short_address
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16))
      return self.saved_token
    end
  end

  def formatted_for_select
    ["#{self.name}, #{self.location.try(:short_address)}", self.id]
  end
end
