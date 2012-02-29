class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :hospital
  belongs_to :clinic
  belongs_to :city
  
  def in_clinic?
    clinic.present?
  end
  
  def in_hospital?
    hospital.present?
  end
  
  def address
    if in_clinic?
      
      output = ""
      
      if (suite.present? and details.present?) 
        output += "#{suite} - #{details}, #{clinic.name}"
      elsif suite.present?
        output += "Suite #{suite}, #{clinic.name}"
      else
        output += "#{clinic.name}"
      end
      
      if (clinic.addresses.first.present? and (not clinic.addresses.first.empty?))
        output += ", #{clinic.addresses.first.address}"
      end
      
      return output
      
    elsif in_hospital?
      
      output = ""
      
      if (suite.present? and details.present?) 
        output += "#{suite} - #{details}, #{hospital.name}"
      elsif suite.present?
        output += "Suite #{suite}, #{hospital.name}"
      else
        output += "#{hospital.name}"
      end
      
      if (hospital.addresses.first.present? and (not hospital.addresses.first.empty?))
        output += ", #{hospital.addresses.first.address}"
      end
      
      return output
      
    else
      
      output = ""
    
      if suite.present? and (address1.present? or address2.present?)
        output += "#{suite} - "
      elsif suite.present?
        output += "Suite #{suite}, "
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
  end
  
  def phone_and_fax
    if phone1.present? and fax.present?
      return "#{phone1}, Fax: #{fax}"
    elsif phone1.present?
      return "#{phone1}"
    elsif fax.present?
      return "fax: #{fax}"
    else
      return ""
    end
  end
  
  def empty?
    (suite.blank? and address1.blank? and address2.blank? and (not city) and postalcode.blank? and phone1.blank? and fax.blank? and hospital_id.blank? and clinic_id.blank? and details.blank?)
  end
  
  def map_url
    if (in_clinic? and clinic.addresses.first.present? and (not clinic.addresses.first.empty?))
      return clinic.addresses.first.map_url
    elsif (in_hospital? and hospital.addresses.first.present? and (not hospital.addresses.first.empty?))
      return hospital.addresses.first.map_url
    elsif ((not in_clinic?) and (not in_hospital?))
      return "http://maps.google.com?q=#{address}"
    else
      return ""
    end
  end
end
