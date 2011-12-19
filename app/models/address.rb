class Address < ActiveRecord::Base
  has_paper_trail
  belongs_to :hospital
  belongs_to :city
  
  def address
    output = ""
    if address2.present? and address1.present?
      output = "#{address2} - #{address1}, "
    elsif address2.present?
      output = "#{address2}, "
    elsif address1.present?
      output = "#{address1}, "
    end
    
    if city
      output += "#{city}, #{city.province}, "
    end
    
    if postalcode.present?
      output = "#{postalcode}, "
    end
    
    return output[0..-3]
  end
  
  def empty?
    address1.blank? and address2.blank? and (not city) and postalcode.blank? and phone1.blank? and fax.blank? and hospital_id.blank?
  end
end
