class Address < ActiveRecord::Base
  include PaperTrailable
  belongs_to :city
  has_many :locations

  has_many :direct_offices,
    through: :locations,
    source: :locatable,
    source_type: "Office"

  has_many :locations_in, through: :locations, class_name: "Location"
  has_many :offices_in_clinics,
    through: :locations_in,
    source: :locatable,
    source_type: "Office"

  has_many :hospitals, through: :locations, source: :locatable, source_type: "Hospital"
  has_many :office_locations_in_hospitals,
    -> { where('"locations_offices_in_hospitals_join"."locatable_type" = ?', 'Office') },
    through: :hospitals,
    source: :locations_in,
    class_name: "Location"
  has_many :offices_in_hospitals,
    through: :office_locations_in_hospitals,
    source: :locatable,
    source_type: "Office"

  has_many :clinic_locations_in_hospitals,
    -> { where(
      '"clinic_locations_in_hospitals_offices_in_clinics_in_hospitals_join".'\
        '"locatable_type" = ?',
      "ClinicLocation"
    ) },
    through: :hospitals,
    source: :locations_in,
    class_name: "Location"
  has_many :locations_in_clinics_in_hospitals,
    through: :clinic_locations_in_hospitals,
    source: :locations_in,
    class_name: "Location"
  has_many :offices_in_clinics_in_hospitals,
    through: :locations_in_clinics_in_hospitals,
    source: :locatable,
    source_type: "Office"

  def offices
    direct_offices +
      offices_in_clinics +
      offices_in_hospitals +
      offices_in_clinics_in_hospitals
  end

  def address
    output = ""

    output += "##{suite}, " if suite.present?
    output += "#{address1}, " if address1.present?
    output += "#{address2}, " if address2.present?
    output += "#{city}, #{city.province}, " if city.present?
    output += "#{postalcode}, "  if postalcode.present?

    return output[0..-3]
  end

  def short_address
    output = ""

    output += "##{suite}, " if suite.present?
    output += "#{address1}, " if address1.present?
    output += "#{address2}, " if address2.present?
    output += "#{city}, " if city.present?

    return output[0..-3]
  end


  def phone_and_fax
    return "#{phone1}, Fax: #{fax}" if (phone1.present? && fax.present?)
    return "#{phone1}" if phone1.present?
    return "fax: #{fax}" if fax.present?
    return ""
  end

  def empty?
    (
      suite.blank? and
      address1.blank? and
      address2.blank? and
      (not city) and
      postalcode.blank?
    )
  end

  def map_url
    search = ""
    search += "#{address1}, " if address1.present?
    search += "#{city}, #{city.province}, " if city.present?
    search += "#{postalcode}, " if postalcode.present?
    return "https://maps.google.com?q=#{search} Canada"
  end

  def map_image(width, height, zoom, scale)
    search = ""
    search += "#{address1}, " if address1.present?
    search += "#{city}, #{city.province}, " if city.present?
    search += "#{postalcode}, " if postalcode.present?
    return "https://maps.googleapis.com/maps/api/staticmap?size=#{width}x#{height}&"\
      "zoom=#{zoom}&scale=#{scale}&sensor=false&markers=#{search} Canada"
  end

  def divisions
    city.present? ? city.divisions : []
  end

  def to_s
    return address
  end
end
