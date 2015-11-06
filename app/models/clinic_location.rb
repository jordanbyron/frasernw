class ClinicLocation < ActiveRecord::Base
  attr_accessible :clinic_id,
    :phone,
    :phone_extension,
    :fax,
    :contact_details,
    :sector_mask,
    :url,
    :public_email,
    :email,
    :wheelchair_accessible_mask,
    :schedule_attributes,
    :location_attributes,
    :attendances_attributes,
    :location_opened

  SECTORS = [
    :public,
    :private,
    :volunteer
  ]

  attr_accessible *SECTORS

  belongs_to :clinic
  has_one :location, :as => :locatable, :dependent => :destroy
  accepts_nested_attributes_for :location

  has_one :schedule, :as => :schedulable, :dependent => :destroy
  accepts_nested_attributes_for :schedule

  has_many :user_controls_clinic_locations, :dependent => :destroy
  has_many :controlling_users, :through => :user_controls_clinic_locations, :source => :user, :class_name => "User"

  has_many :attendances, :dependent => :destroy
  accepts_nested_attributes_for :attendances, :allow_destroy => true

  include PaperTrailable

  def self.all_formatted_for_user_form
    includes([:clinic, :location => [ {:address => :city}, {:hospital_in => {:location => {:address => :city}}} ]]).all.reject{ |cl| cl.location.blank? || cl.empty? || cl.clinic.blank? }.sort{ |a,b| a.clinic.name <=> b.clinic.name }.map{ |cl| ["#{cl.clinic.name} - #{cl.location.short_address}", cl.id]}
  end

  def opened_recently?
    (location_opened == Time.now.year.to_s) || (([1,2].include? Time.now.month) && (location_opened == (Time.now.year - 1).to_s))
  end

  def city
    l = location;
    return nil if l.blank?
    return l.city
  end

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

  def sector_info_available
    SECTORS.any? do |sector|
      send(sector).is_a?(TrueClass) || send(sector).is_a?(FalseClass)
    end
  end

  def sector?
    sector_mask != 4
  end

  def scheduled?
    schedule.scheduled?
  end

  def empty?
    phone.blank? && phone_extension.blank? && fax.blank? && contact_details.blank? && (location.blank? || location.empty?)
  end

  def has_data?
    !empty?
  end

  def visible?
    city && !city.hidden?
  end
end
