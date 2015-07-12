class SpecialistOffice < ActiveRecord::Base
  attr_accessible :phone, :phone_extension, :fax, :direct_phone, :direct_phone_extension, :sector_mask, :public_email, :email, :open_saturday, :open_sunday, :office_id, :office_attributes, :phone_schedule_attributes, :url, :location_opened

  belongs_to :specialist, touch: true
  belongs_to :office
  accepts_nested_attributes_for :office

  has_many :user_controls_specialist_offices, :dependent => :destroy
  has_many :controlling_users, :through => :user_controls_specialist_offices, :source => :user, :class_name => "User"

  #offices have a phone schedule
  has_one :phone_schedule, :as => :schedulable, :dependent => :destroy, :class_name => "Schedule"
  accepts_nested_attributes_for :phone_schedule

  after_commit :flush_cache
  after_touch  :flush_cache

  include PaperTrailable

  default_scope order('specialist_offices.id ASC')

  # # # # # # # # CACHING METHODS
  def self.all_formatted_for_user_form
    includes([:specialist, :office => [:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]]]).all.reject{ |so| so.office.blank? || so.empty? || so.specialist.blank? }.sort{ |a,b| (a.specialist.lastname || "zzz") <=> (b.specialist.lastname || "zzz") }.map{ |so| ["#{so.specialist.name} - #{so.office.short_address}", so.id]}
  end

  def self.refresh_cached_all_formatted_for_user_form
    Rails.cache.write([name, "all_specialist_office_formatted_for_user_form"], self.all_formatted_for_user_form)
  end

  def self.cached_all_formatted_for_user_form
    Rails.cache.fetch([name, "all_specialist_office_formatted_for_user_form"], expires_in: 6.hours) {self.all_formatted_for_user_form}
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]){find(id)}
  end

  def flush_cache #called during after_commit or after_touch
    Rails.cache.delete([self.class.name, "all_specialist_office_formatted_for_user_form"])
    Rails.cache.delete([self.class.name, self.id])
  end

  def self.refresh_cache
    Rails.cache.write([name, "all_specialist_office_formatted_for_user_form"], self.all_formatted_for_user_form)
    SpecialistOffice.all.each do |office|
      Rails.cache.write([office.class.name, office.id], SpecialistOffice.find(office.id))
    end
  end
  # # # # # # # #

  def self.all_formatted_for_user_form
    includes([:specialist, :office => [:location => [ {:address => :city}, {:location_in => [{:address => :city}, {:hospital_in => {:location => {:address => :city}}}]}, {:hospital_in => {:location => {:address => :city}}} ]]]).all.reject{ |so| so.office.blank? || so.empty? || so.specialist.blank? }.sort{ |a,b| (a.specialist.lastname || "zzz") <=> (b.specialist.lastname || "zzz") }.map{ |so| ["#{so.specialist.name} - #{so.office.short_address}", so.id]}
  end

  def opened_recently?
    (location_opened == Time.now.year.to_s) || (([1,2].include? Time.now.month) && (location_opened == (Time.now.year - 1).to_s))
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

  def direct_info
    return "#{direct_phone} ext. #{direct_phone_extension}" if direct_phone.present? && direct_phone_extension.present?
    return "#{direct_phone}" if direct_phone.present?
    return "ext. #{direct_phone_extension}" if direct_phone_extension.present?
    return ""
  end

  SECTOR_HASH = {
    1 => "Public (MSP billed)",
    2 => "Private (Patient pays)",
    3 => "Public and Private",
    4 => "Didn't answer",
  }

  def sector
    SpecialistOffice::SECTOR_HASH[sector_mask]
  end

  def sector?
    #we assume public for specialists
    sector_mask != 1 && sector_mask != 4
  end

  def city
    o = office
    return nil if o.blank?
    return o.city
  end

  def has_data?
    !empty?
  end

  def empty?
    phone.blank? && phone_extension.blank? && fax.blank? && direct_phone.blank? && direct_phone_extension.blank? && (office.blank? || office.empty?)
  end

  def location
    office.try(:location)
  end
end
