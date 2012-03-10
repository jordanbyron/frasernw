class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :city
  has_many :locations
  
  def address
    output = ""
  
    if suite.present? and (address1.present? or address2.present?)
      output += "#{suite} - "
    elsif suite.present?
      output += "#{suite}, "
    end
    
    output += "#{address1}, " if address1.present?
    output += "#{address2}, " if address2.present?
    output += "#{city}, #{city.province}, " if city.present?
    output += "#{postalcode}, "  if postalcode.present?
    
    return output[0..-3]
  end
  
  def short_address
    output = ""
  
    if suite.present? and (address1.present? or address2.present?)
      output += "#{suite} - "
    elsif suite.present?
      output += "#{suite}"
    end
    
    output += "#{address1}, " if address1.present?
    output += "#{address2}, " if address2.present?
    
    return output[0..-3]
  end
    
  
  def phone_and_fax
    return "#{phone1}, Fax: #{fax}" if (phone1.present? && fax.present?)
    return "#{phone1}" if phone1.present?
    return "fax: #{fax}" if fax.present?
    return ""
  end
  
  def empty_old?
    (suite.blank? and address1.blank? and address2.blank? and (not city) and postalcode.blank? and phone1.blank? and fax.blank? and hospital_id.blank? and clinic_id.blank?)
  end
  
  def empty?
    (suite.blank? and address1.blank? and address2.blank? and (not city) and postalcode.blank?)
  end
  
  def map_url
    search = ""
    search += "#{address1}, " if address1.present?
    search += "#{city}, #{city.province}, " if city.present?
    search += "#{postalcode}, " if postalcode.present?
    return "http://maps.google.com?q=#{search} Canada"
  end
  
  def to_s
    return address
  end
end
