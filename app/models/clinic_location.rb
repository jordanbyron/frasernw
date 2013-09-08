class ClinicLocation < ActiveRecord::Base
  
  attr_accessible :clinic_id, :phone, :phone_extension, :fax, :contact_details, :sector_mask, :url, :email, :wheelchair_accessible_mask, :schedule_attributes, :location_attributes

  belongs_to :clinic
  has_one :location, :as => :locatable
  accepts_nested_attributes_for :location
  
  has_one :schedule, :as => :schedulable, :dependent => :destroy
  accepts_nested_attributes_for :schedule
  
  def resolved_address
    return location.resolved_address if location.present?
    return nil
  end
  
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
  
  def phone_only
    return "#{phone} ext. #{phone_extension}" if phone.present? && phone_extension.present?
    return "#{phone}" if phone.present?
    return "ext. #{phone_extension}" if phone_extension.present?
    return ""
  end
  
  def wheelchair_accessible?
    wheelchair_accessible_mask == 1
  end
  
  SECTOR_HASH = {
    1 => "Public (MSP billed)",
    2 => "Private (Patient pays)",
    3 => "Public and Private",
    4 => "Didn't answer",
  }
  
  def sector
    ClinicLocation::SECTOR_HASH[sector_mask]
  end
  
  def sector?
    sector_mask != 4
  end
  
  def private?
    sector_mask == 2
  end
  
  def scheduled?
    schedule.scheduled?
  end
  
  def empty?
    phone.blank? && phone_extension.blank? && fax.blank? && contact_details.blank? && !sector? && url.blank? && email.blank? && !wheelchair_accessible? && !scheduled? && (location.blank? || location.empty?) 
  end
  
  has_paper_trail
end
