class Clinic < ActiveRecord::Base
  include PaperTrailable
  include Reviewable
  include Feedbackable
  include Historical
  include Noteable
  include ProcedureSpecializable
  include Referrable
  include ApplicationHelper
  include TokenAccessible
  include OffersTeleservices
  include DivisionAdministered

  attr_accessible :name,
    :deprecated_phone,
    :deprecated_phone_extension,
    :deprecated_fax,
    :deprecated_contact_details,
    :categorization_mask,
    :deprecated_sector_mask,
    :deprecated_url,
    :deprecated_email,
    :deprecated_wheelchair_accessible_mask,
    :status,
    :practice_details,
    :referral_criteria,
    :referral_process,
    :contact_name,
    :contact_email,
    :contact_phone,
    :contact_notes,
    :status_mask,
    :limitations,
    :required_investigations,
    :not_performed,
    :referral_fax,
    :referral_phone,
    :referral_other_details,
    :referral_details,
    :referral_form_mask,
    :lagtime_mask,
    :waittime_mask,
    :respond_by_fax,
    :respond_by_phone,
    :respond_by_mail,
    :respond_to_patient,
    :patient_can_book_mask,
    :red_flags,
    :urgent_fax,
    :urgent_phone,
    :urgent_other_details,
    :urgent_details,
    :responds_via,
    :patient_instructions,
    :cancellation_policy,
    :interpreter_available,
    :specialization_ids,
    :deprecated_schedule_attributes,
    :language_ids,
    :attendances_attributes,
    :focuses_attributes,
    :healthcare_provider_ids,
    :admin_notes,
    :referral_forms_attributes,
    :clinic_locations_attributes,
    :review_object,
    :hidden,
    :completed_survey,
    :accepting_new_referrals,
    :referrals_limited,
    :closure_scheduled,
    :closure_date,
    :teleservices_require_review

  has_many :clinic_specializations, dependent: :destroy
  has_many :specializations, through: :clinic_specializations

  MAX_LOCATIONS = 9
  has_many :clinic_locations, dependent: :destroy
  accepts_nested_attributes_for :clinic_locations
  has_many :locations, through: :clinic_locations
  has_many :addresses, through: :locations

  has_many :clinic_speaks, dependent: :destroy
  has_many :languages, through: :clinic_speaks

  has_many :focuses, dependent: :destroy

  has_many :procedure_specialization_links, class_name: "Focus"
  has_many :procedure_specializations, through: :focuses
  has_many :procedures, through: :procedure_specializations
  accepts_nested_attributes_for :focuses,
    reject_if: lambda { |a| a[:procedure_specialization_id].blank? },
    allow_destroy: true

  has_many :attendances, through: :clinic_locations
  has_many :specialists, through: :attendances

  has_many :clinic_healthcare_providers, dependent: :destroy
  has_many :healthcare_providers, through: :clinic_healthcare_providers

  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :favoriting_users,
    through: :favorites,
    source: :user,
    class_name: "User"

  has_many :controlling_users,
    through: :user_controls_clinics,
    source: :user,
    class_name: "User"
  has_many :user_controls_clinics, dependent: :destroy
  alias user_controls user_controls_clinics

  default_scope { order('clinics.name') }

  scope :hidden, -> { where(hidden: true) }

  def self.includes_location_data
    includes_clinic_locations.includes_locations
  end

  def self.includes_clinic_locations
    includes(
      clinic_locations: {
        location: [
          { address: :city },
          { hospital_in: { location: { address: :city } } },
        ]
      }
    )
  end

  def self.includes_location_schedules
    includes(
      clinic_locations: {schedule: [
        :monday,
        :tuesday,
        :wednesday,
        :thursday,
        :friday,
        :saturday,
        :sunday
      ] }
    )
  end

  def self.includes_locations
    includes(
      locations: [
        { address: :city },
        { hospital_in: { location: { address: :city } } },
      ]
    )
  end

  CATEGORIZATION_LABELS = {
    1 => "Responded to survey",
    2 => "Not responded to survey",
    3 => "Purposely not yet surveyed",
  }

  def self.in_cities(cities)
    city_ids = cities.map{ |city| city.id }
    direct = joins(
      'INNER JOIN "clinic_locations" AS "direct_clinic_location" '\
        'ON "clinics".id = "direct_clinic_location".clinic_id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "direct_clinic_location".id = "direct_location".locatable_id '\
        'INNER JOIN "addresses" AS "direct_address" '\
        'ON "direct_location".address_id = "direct_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_address".city_id IN (?) '\
        'AND "direct_location".hospital_in_id IS NULL',
      "ClinicLocation",
      city_ids
    )
    in_hospital = joins(
      'INNER JOIN "clinic_locations" AS "direct_clinic_location" '\
        'ON "clinics".id = "direct_clinic_location".clinic_id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "direct_clinic_location".id = "direct_location".locatable_id '\
        'INNER JOIN "hospitals" '\
        'ON "hospitals".id = "direct_location".hospital_in_id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?)',
      "ClinicLocation",
      "Hospital",
      city_ids
    )
    (direct + in_hospital).uniq
  end

  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end

  def self.no_specialization
    @no_specialization ||=
      includes(:specializations).
        where('specializations.id IS NULL').
        references(:specializations)
  end

  def self.no_division
    includes_location_data.reject do |clinic|
      clinic.cities.length > 0
    end.sort do |a,b|
      a.name <=> b.name
    end
  end

  def show_waittimes?
    open? && completed_survey? && accepting_new_referrals?
  end

  def cities
    locations.map(&:city).reject(&:blank?).uniq
  end

  def divisions
    cities.map(&:divisions).flatten.uniq
  end

  def referral_icon_key
    if !completed_survey?
      :question_mark
    elsif open? && accepting_new_referrals? && referrals_limited?
      :orange_check
    elsif open? && accepting_new_referrals?
      :green_check
    else
      :red_x
    end
  end

  def referral_summary
    if !completed_survey?
      "It is unknown whether this clinic is accepting new referrals."
    elsif open? && accepting_new_referrals? && referrals_limited?
      "This clinic is accepting new referrals limited by geography or number of patients."
    elsif open? && accepting_new_referrals?
      "This clinic is accepting new referrals."
    elsif open?
      "This clinic is not accepting new referrals."
    else
      "This clinic is closed"
    end
  end

  WAITTIME_LABELS = Specialist::WAITTIME_LABELS

  def waittime
    waittime_mask.present? ? Clinic::WAITTIME_LABELS[waittime_mask] : ""
  end

  LAGTIME_LABELS = {
    1 => "Book by phone when office calls for referral",
    2 => "Within one week",
    3 => "1-2 weeks",
    4 => "2-4 weeks",
    5 => "1-2 months",
    6 => "2-4 months",
    7 => "4-6 months",
    8 => "6-9 months",
    9 => "9-12 months",
    10 => "12-18 months",
    11 => "18-24 months",
    12 => "2-2.5 years",
    13 => "2.5-3 years",
    14 => ">3 years"
  }

  def lagtime
    Clinic::LAGTIME_LABELS[lagtime_mask]
  end

  BOOLEAN_HASH = {
    1 => "Yes",
    2 => "No",
    3 => "Didn't answer",
  }

  def patient_can_book?
    patient_can_book_mask == 1
  end

  def accepts_referrals_via
    if referral_phone && referral_fax && referral_other_details.present?
      output = "phone, fax, or #{referral_other_details}"
    elsif referral_phone && referral_fax
      output = "phone or fax"
    elsif referral_phone
      if referral_other_details.present?
        output = "phone or #{referral_other_details}"
      else
        output = "phone"
      end
    elsif referral_fax
      if referral_other_details.present?
        output = "fax or #{referral_other_details}"
      else
        output = "fax"
      end
    elsif referral_other_details.present?
      output = referral_other_details
    else
      output = ""
    end

    if referral_details.present?
      return "#{output.punctuate} "\
        "#{referral_details.punctuate.convert_newlines_to_br}".
          html_safe
    else
      return output.punctuate
    end
  end

  def responds_via
    if (
      (not respond_by_phone) &&
      (not respond_by_fax) &&
      (not respond_by_mail) &&
      (not respond_to_patient)
    )
      return ""
    elsif (
      (not respond_by_phone) &&
      (not respond_by_fax) &&
      (not respond_by_mail) &&
      respond_to_patient
    )
      return "Directly contacting the patient."
    else
      if respond_by_phone && respond_by_fax && respond_by_mail
        output = "phone, fax, or mail to referring office"
      elsif respond_by_phone && respond_by_fax && (not respond_by_mail)
        output = "phone or fax to referring office"
      elsif respond_by_phone && (not respond_by_fax) && respond_by_mail
        output = "phone or mail to referring office"
      elsif respond_by_phone && (not respond_by_fax) && (not respond_by_mail)
        output = "phone to referring office"
      elsif (not respond_by_phone) && respond_by_fax && respond_by_mail
        output = "fax or mail to referring office"
      elsif (not respond_by_phone) && respond_by_fax && (not respond_by_mail)
        output = "fax to referring office"
      else
        output = "mail to referring office"
      end

      if respond_to_patient
        return output.capitalize_first_letter +
          ", and by directly contacting the patient."
      else
        return output.end_with_period
      end
    end
  end

  def urgent_referrals_via
    if urgent_phone && urgent_fax
      if urgent_other_details.present?
        output = "phone, fax, or #{urgent_other_details}"
      else
        output = "phone or fax"
      end
    elsif urgent_phone
      if urgent_other_details.present?
        output = "phone or #{urgent_other_details}"
      else
        output = "phone"
      end
    elsif urgent_fax
      if urgent_other_details.present?
        output = "fax or #{urgent_other_details}"
      else
        output = "fax"
      end
    elsif urgent_other_details.present?
      output = urgent_other_details.punctuate
    else
      output = ""
    end

    if urgent_details.present?
      return "#{output.punctuate} "\
        "#{urgent_details.punctuate.convert_newlines_to_br}".
          html_safe
    else
      return output.punctuate
    end
  end

  def opened_recently?
    clinic_locations.any?(&:opened_recently?)
  end

  def wheelchair_accessible?
    clinic_locations.any?(&:wheelchair_accessible?)
  end

  def days
    clinic_locations.
      select(&:scheduled?).
      map(&:schedule).
      map(&:days).
      flatten.
      uniq
  end

  def scheduled_day_ids
    clinic_locations.map do |cl|
      cl.schedule.scheduled_day_ids
    end.flatten.uniq
  end

  Sectorable::SECTORS.each do |sector|
    define_method "#{sector.to_s}?" do
      clinic_locations.select(&:has_data?).any?(&("#{sector.to_s}?".to_sym))
    end
  end

  # Some locations are built on page load, so they won't have timestamps
  def ordered_clinic_locations
    clinic_locations.sort_by do |location|
      [ (location.has_data? ? 0 : 1), ( location.created_at || DateTime.now ) ]
    end
  end

  def new?
    (created_at > 3.week.ago.utc) && opened_recently?
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16))
      return self.saved_token
    end
  end

  def label
    name
  end

  def visible_attendances
    @visible_attendances ||= attendances.select(&:show?)
  end

  def specialists_with_offices_in
    clinic_locations.
      map(&:location).
      map{|location| Location.where(location_in_id: location.id) }.
      flatten.
      map(&:locatable).
      select{|locatable| locatable.is_a?(Office) }.
      map{|office| SpecialistOffice.where(office_id: office.id) }.
      flatten.
      map(&:specialist).
      uniq
  end

  def hospitals_in
    clinic_locations.
      select(&:has_data?).
      map(&:location).
      reject(&:nil?).
      select(&:in_hospital?).
      map(&:hospital_in).
      reject(&:nil?).
      uniq
  end

  def unavailable_for_a_while?
    !open? && closure_date.present? && closure_date <= (Date.current - 2.years)
  end

  def locations_showing_attendances
    @locations_showing_attendances ||= clinic_locations.select do |location|
      location.resolved_address.present? &&
        location.attendances.select(&:show?).any?
    end
  end

  def open?
    !closed?
  end

  def closed?
    closure_scheduled? && closure_date <= Date.current
  end
end
