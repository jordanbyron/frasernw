class SpecialistOffice < ActiveRecord::Base
  include Sectorable

  attr_accessible :phone,
    :phone_extension,
    :fax,
    :direct_phone,
    :direct_phone_extension,
    :contact_details,
    :sector_mask,
    :public_email,
    :email,
    :open_saturday,
    :open_sunday,
    :office_id,
    :office_attributes,
    :phone_schedule_attributes,
    :url,
    :location_opened,
    :location_is

  belongs_to :specialist, touch: true
  belongs_to :office
  accepts_nested_attributes_for :office

  #offices have a phone schedule
  has_one :phone_schedule, as: :schedulable, dependent: :destroy, class_name: "Schedule"
  accepts_nested_attributes_for :phone_schedule

  after_commit :flush_cache
  after_touch  :flush_cache

  include PaperTrailable

  default_scope { order('specialist_offices.id ASC') }

  def self.all_formatted_for_user_form
    includes( [
      :specialist,
      office: [ location: [
        { address: :city },
        { location_in: [
          { address: :city },
          { hospital_in: { location: { address: :city } } }
        ] },
        { hospital_in: { location: { address: :city } } }
      ] ]
    ] ).
    reject{ |so| so.office.blank? || so.empty? || so.specialist.blank? }.
    sort{ |a,b| (a.specialist.lastname || "zzz") <=> (b.specialist.lastname || "zzz") }.
    map{ |so| ["#{so.specialist.name} - #{so.office.short_address}", so.id] }
  end

  def self.refresh_cached_all_formatted_for_user_form
    Rails.cache.write(
      [name, "all_specialist_office_formatted_for_user_form"],
      self.all_formatted_for_user_form
    )
  end

  def self.cached_all_formatted_for_user_form
    Rails.cache.fetch(
      [name, "all_specialist_office_formatted_for_user_form"],
      expires_in: 6.hours
    ) { self.all_formatted_for_user_form }
  end

  def flush_cache
    Rails.cache.delete(
      [self.class.name, "all_specialist_office_formatted_for_user_form"]
    )
    Rails.cache.delete([self.class.name, self.id])
  end

  def self.refresh_cache
    Rails.cache.write(
      [name, "all_specialist_office_formatted_for_user_form"],
      self.all_formatted_for_user_form
    )
    SpecialistOffice.all.each do |office|
      Rails.cache.write([office.class.name, office.id], SpecialistOffice.find(office.id))
    end
  end

  def self.all_formatted_for_user_form
    includes( [
      :specialist,
      office: [location: [
        { address: :city },
        { location_in: [
          { address: :city },
          { hospital_in: { location: { address: :city } } }
        ] },
        { hospital_in: { location: { address: :city } } }
      ] ]
    ] ).
    reject{ |so| so.office.blank? || so.empty? || so.specialist.blank? }.
    sort{ |a,b| (a.specialist.lastname || "zzz") <=> (b.specialist.lastname || "zzz") }.
    map{ |so| ["#{so.specialist.name} - #{so.office.short_address}", so.id]}
  end

  def opened_recently?
    (location_opened == Time.now.year.to_s) ||
      (([1,2].include? Time.now.month) && (location_opened == (Time.now.year - 1).to_s))
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

  def phone_only
    if phone.present? && phone_extension.present?
      "#{phone} ext. #{phone_extension}"
    elsif phone.present?
      "#{phone}"
    elsif phone_extension.present?
      "ext. #{phone_extension}"
    else
      ""
    end
  end

  def direct_info
    if direct_phone.present? && direct_phone_extension.present?
      "#{direct_phone} ext. #{direct_phone_extension}"
    elsif direct_phone.present?
      "#{direct_phone}"
    elsif direct_phone_extension.present?
      "ext. #{direct_phone_extension}"
    else
      ""
    end
  end

  def show_sector_info?
    # because 'public' used to be default

    sector_info_available? && !public?
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
    phone.blank? &&
    phone_extension.blank? &&
    fax.blank? &&
    direct_phone.blank? &&
    direct_phone_extension.blank? &&
    (office.blank? || office.empty?)
  end

  def location
    office.try(:location)
  end

  LOCATION_IS_OPTIONS = {
    0 => 'Not used',
    1 => 'In an existing office',
    2 => 'In a new standalone office',
    3 => 'In a new office in a hospital',
    4 => 'In a new office in a clinic',
    5 => 'In an office'
  }

  def location_is
    if new_record? || empty?
      0
    else
      5
    end
  end

  def location_is_options
    if new_record?
      LOCATION_IS_OPTIONS.slice(0, 1, 2, 3, 4)
    else
      LOCATION_IS_OPTIONS.slice(0, 5)
    end
  end
end
