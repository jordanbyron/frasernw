class SpecialistOffice < ActiveRecord::Base
  attr_accessible :phone, :phone_extension, :fax, :sector_mask, :office_id, :office_attributes
  
  belongs_to :specialist
  belongs_to :office
  accepts_nested_attributes_for :office
  
  has_paper_trail
  
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
  
  SECTOR_HASH = { 
    1 => "Public", 
    2 => "Private", 
    3 => "Public and Private", 
    4 => "Didn't answer", 
  }
  
  def sector
    SpecialistOffice::SECTOR_HASH[sector_mask]
  end
  
  def sector?
    sector_mask != 4
  end
  
  def empty?
    phone.blank? && phone_extension.blank? && fax.blank? && office.blank?
  end
end
