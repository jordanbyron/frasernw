class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :hospital
  belongs_to :clinic
  belongs_to :city
  
  def address
    output = ""
    
    if suite.present? and (address1.present? or address2.present?)
      output += "#{suite} - "
    elsif suite.present?
      output += "#{suite}, "
    end
    
    if address1.present?
      output += "#{address1}, "
    end
    
    if address2.present?
      output += "#{address2}, "
    end
    
    if city
      output += "#{city}, #{city.province}, "
    end
    
    if postalcode.present?
      output += "#{postalcode}, "
    end
    
    return output[0..-3]
  end
  
  def phone_and_fax
    if phone1.present? and fax.present?
      return "#{phone1}, fax: #{fax}"
    elsif phone1.present?
      return "#{phone1}"
    elsif fax.present?
      return "fax: #{fax}"
    else
      return ""
    end
  end
  
  def empty?
    suite.blank? and address1.blank? and address2.blank? and (not city) and postalcode.blank? and phone1.blank? and fax.blank? and hospital_id.blank? and clinic_id.blank?
  end
end
