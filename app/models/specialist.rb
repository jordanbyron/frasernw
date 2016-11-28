class Specialist < ActiveRecord::Base
  include PaperTrailable
  include Reviewable
  include Feedbackable
  include Historical
  include Noteable
  include ProcedureSpecializable
  include Referrable
  include TokenAccessible
  include OffersTeleservices
  include DivisionAdministered
  include ApplicationHelper
  include HasWaitTimes

  attr_accessible :firstname,
    :lastname,
    :goes_by_name,
    :sex_mask,
    :categorization_mask,
    :billing_number,
    :is_gp,
    :is_internal_medicine,
    :sees_only_children,
    :practice_limitations,
    :interest,
    :red_flags,
    :clinic_location_ids,
    :responds_via,
    :contact_name,
    :contact_email,
    :contact_phone,
    :contact_notes,
    :referral_criteria,
    :status_mask,
    :referral_fax,
    :referral_phone,
    :referral_clinic_id,
    :referral_other_details,
    :referral_details,
    :urgent_fax,
    :urgent_phone,
    :urgent_other_details,
    :urgent_details,
    :respond_by_fax,
    :respond_by_phone,
    :respond_by_mail,
    :respond_to_patient,
    :status_details,
    :required_investigations,
    :not_performed,
    :patient_can_book_mask,
    :referral_form_mask,
    :patient_instructions,
    :cancellation_policy,
    :hospital_clinic_details,
    :interpreter_available,
    :photo,
    :photo_delete,
    :hospital_ids,
    :specialization_ids,
    :language_ids,
    :specialist_offices_attributes,
    :admin_notes,
    :referral_forms_attributes,
    :review_object,
    :hidden,
    :completed_survey,
    :works_from_offices,
    :accepting_new_direct_referrals,
    :direct_referrals_limited,
    :practice_end_date,
    :practice_restart_date,
    :practice_end_scheduled,
    :practice_restart_scheduled,
    :practice_end_reason_key,
    :practice_details,
    :accepting_new_indirect_referrals,
    :teleservices_require_review

  procedure_specialize_as "specialist"

  # specialists attend clinics
  has_many :attendances, dependent: :destroy
  has_many :clinic_locations, through: :attendances
  has_many :clinics, through: :clinic_locations

  # specialists have "priviliges" at hospitals
  has_many :privileges, dependent: :destroy
  has_many :hospitals, through: :privileges

  # specialists "speak" many languages
  has_many :specialist_speaks, dependent: :destroy
  has_many :languages, through: :specialist_speaks

  # specialists are favorited by users of the system
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :favoriting_users,
    through: :favorites,
    source: :user,
    class_name: "User"

  # has many contacts - dates and times they were contacted
  has_many :contacts

  # dates and times they looked at and changed their own record
  has_many :views
  has_many :edits

  MAX_OFFICES = 4
  has_many :specialist_offices, dependent: :destroy
  has_many :offices, through: :specialist_offices
  has_many :locations, through: :offices
  accepts_nested_attributes_for :specialist_offices

  #specialist are controlled (e.g. can be edited) by users of the system
  has_many :controlling_users,
    through: :user_controls_specialists,
    source: :user,
    class_name: "User"
  has_many :user_controls_specialists, dependent: :destroy
  alias user_controls user_controls_specialists

  has_attached_file :photo,
    styles: { thumb: "200x200#" },
    storage: :s3,
    bucket: Pathways::S3.switchable_bucket_name(:specialist_photos),
    s3_protocol: :https,
    s3_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }

  before_save :destroy_photo?

  after_commit :expire_cache
  after_touch  :expire_cache

  scope :hidden, -> { where(hidden: true) }

  def self.with_cities
    includes({
      hospitals: { location: {address: :city } },
      offices: { location: [
        { address: :city },
        { hospital_in: { location: { address: :city } } },
        { location_in: [
          {address: :city },
          {hospital_in: { location: { address: :city } } }
        ] }
      ] },
      clinics: { locations: [
        { address: :city },
        { hospital_in: { location: { address: :city } } },
      ] }
    })
  end

  def self.includes_specialization_page
    includes([
      :procedures,
      :specializations,
      :languages,
      :teleservices
    ]).includes(specialist_procedures: :procedure).with_cities
  end

  def self.cache_key
    max_updated_at = maximum(:updated_at).try(:utc).try(:to_s, :number)
    sum_of_ids = limit(100).pluck(:id).try(:compact).inject{ |sum, id| sum + id }
    "specialists/all-#{count}-#{max_updated_at}-#{sum_of_ids}"
    # since cache_key acts on a subset of Specialist records; sum_of_ids was added to
    # reduce the chance of an incorrect cache hit should two collections ever have
    # matching count / max updated_at values
  end

  # TODO: See if .map(&:id) could use .pluck(&:id) here after upgrading to Rails3.2
  def self.in_cities_cached(c)
    # Called using Specialist.in_cities but also @specialization.specialists in places
    # This model cache has potential here for many Cache keys, since the key is dependent
    # on value of 'self's array
    city_ids = Array.wrap(c).map{ |city| city.id }.sort
      specialist_ids_array = Rails.cache.fetch(
        "#{self.cache_key}/-in_cities-#{Digest::SHA1::hexdigest(city_ids.to_s)}",
        expires_in: 23.hours
      ) { self.in_cities(c).map(&:id) }
      # Not ideal as Cache key is dependent on value of 'self's array
      where(id: specialist_ids_array)
  end

  def self.in_divisions_cached(divisions)
    divs = Array.wrap(divisions)
    self.in_cities_cached(divs.map{ |division| division.cities }.flatten.uniq)
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id], expires_in: 4000.seconds) { find(id) }
  end

  def expire_cache
    Rails.cache.delete([self.class.name, self.id])
    cities(force: true)
    ExpireFragment.call(
      Rails.application.routes.url_helpers.specialist_path(self)
    )
  end

  def self.in_cities(c)
    city_ids = Array.wrap(c).map(&:id).sort
    from_own_office = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "addresses" AS "direct_address" '\
        'ON "direct_location".address_id = "direct_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_address".city_id IN (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "direct_location".location_in_id IS NULL '\
        'AND "specialists".works_from_offices = (?)',
      "Office",
      city_ids,
      true
    )

    from_own_office_in_hospital = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "hospitals" '\
        'ON "hospitals".id = "direct_location".hospital_in_id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".works_from_offices = (?)',
      "Office",
      "Hospital",
      city_ids,
      true
    )

    from_own_office_in_clinic = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "locations" AS "clinic_location" '\
        'ON "clinic_location".id = "direct_location".location_in_id '\
        'INNER JOIN "addresses" AS "clinic_address" '\
        'ON "clinic_location".address_id = "clinic_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "clinic_location".locatable_type = (?) '\
        'AND "clinic_location".hospital_in_id IS NULL '\
        'AND "clinic_address".city_id IN (?) '\
        'AND "specialists".works_from_offices = (?)',
      "Office",
      "ClinicLocation",
      city_ids,
      true
    )

    from_own_office_in_clinic_in_hospital = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "locations" AS "clinic_location" '\
        'ON "clinic_location".id = "direct_location".location_in_id '\
        'INNER JOIN "hospitals" '\
        'ON "clinic_location".hospital_in_id = "hospitals".id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "clinic_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".works_from_offices = (?)',
      "Office",
      "ClinicLocation",
      "Hospital",
      city_ids,
      true
    )

    from_hospital = joins(
      'INNER JOIN "privileges" '\
        'ON "specialists"."id" = "privileges"."specialist_id" '\
        'INNER JOIN "hospitals" '\
        'ON "privileges".hospital_id = "hospitals".id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id'
    ).where(
      '"hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND ("specialists".works_from_offices = (?) OR '\
        '("specialists".accepting_new_direct_referrals = (?) AND '\
        '("specialists".accepting_new_indirect_referrals = (?))))',
      "Hospital",
      city_ids,
      false,
      false,
      true
    )

    from_clinic = joins(
      'INNER JOIN "attendances" '\
        'ON "specialists"."id" = "attendances"."specialist_id" '\
        'INNER JOIN "clinic_locations" AS "clinic_in_clinic_location" '\
        'ON "clinic_in_clinic_location".id = "attendances".clinic_location_id '\
        'INNER JOIN "locations" AS "clinic_in_location" '\
        'ON "clinic_in_location".locatable_id = "clinic_in_clinic_location".id '\
        'INNER JOIN "addresses" AS "clinic_address" '\
        'ON "clinic_in_location".address_id = "clinic_address".id'
    ).where(
      '"clinic_in_location".locatable_type = (?) '\
        'AND "clinic_address".city_id IN (?) '\
        'AND "clinic_in_location".hospital_in_id IS NULL '\
        'AND ("specialists".works_from_offices = (?) OR '\
        '("specialists".accepting_new_direct_referrals = (?) AND '\
        '("specialists".accepting_new_indirect_referrals = (?))))',
      "ClinicLocation",
      city_ids,
      false,
      false,
      true
    )

    from_clinic_in_hospital = joins(
      'INNER JOIN "attendances" '\
        'ON "specialists"."id" = "attendances"."specialist_id" '\
        'INNER JOIN "clinic_locations" AS "clinic_in_clinic_location" '\
        'ON "attendances".clinic_location_id = "clinic_in_clinic_location".id '\
        'INNER JOIN "locations" AS "clinic_location" '\
        'ON "clinic_location".locatable_id = "clinic_in_clinic_location".id '\
        'INNER JOIN "hospitals" '\
        'ON "clinic_location".hospital_in_id = "hospitals".id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id'
    ).where(
      '"clinic_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND ("specialists".works_from_offices = (?) OR '\
        '("specialists".accepting_new_direct_referrals = (?) AND '\
        '("specialists".accepting_new_indirect_referrals = (?))))',
      "ClinicLocation",
      "Hospital",
      city_ids,
      false,
      false,
      true
    )

    (
      from_own_office +
      from_own_office_in_hospital +
      from_own_office_in_clinic +
      from_own_office_in_clinic_in_hospital +
      from_hospital +
      from_clinic +
      from_clinic_in_hospital
    ).uniq
  end

  def self.in_divisions(divisions)
    divs = Array.wrap(divisions)

    self.in_cities(divs.map{ |division| division.cities }.flatten.uniq)
  end

  def self.no_division
    self.all - self.in_divisions(Division.all)
  end

  def self.in_multiple_specialties
    @specialists_with_multiple_specialties ||= self.
      joins(:specialist_specializations).
      group('specialists.id').
      having('count(specialist_id) > 1')
  end

  def self.in_multiple_divisions
    @specialists_in_multiple_divisions ||= self.
      includes(specialist_specializations: :specialization).
      includes_specialist_offices.
      select{ |specialist| specialist.divisions.count > 1 }
  end

  def photo_delete
    @photo_delete ||= "0"
  end

  def photo_delete=(value)
    @photo_delete = value
  end

  validates_attachment_content_type :photo, content_type: /image/
  validates_attachment_size :photo, less_than: 2.megabytes

  #clinic that referrals are done through
  belongs_to :referral_clinic, class_name: "Clinic"

  def cities(force: false)
    Rails.cache.fetch([self.class.name, self.id, "cities"], force: force) do
      if works_from_offices? && indirect_referrals_only?
        (
          hospitals.map(&:city) +
          clinic_locations.map(&:city) +
          offices.map(&:city)
        ).flatten.reject(&:blank?).uniq
      elsif works_from_offices?
        offices.map(&:city).reject(&:blank?).uniq
      else
        (
          hospitals.map(&:city) +
          clinic_locations.map(&:city)
        ).flatten.reject(&:blank?).uniq
      end
    end
  end

  def divisions
    cities.map(&:divisions).flatten.uniq
  end

  def version_marked_deceased
    versions.select do |version|
      version.changeset["status_mask"].present? &&
        version.changeset["status_mask"][1] == STATUS_MASK_DECEASED &&
        version.changeset["status_mask"][0] != STATUS_MASK_DECEASED
    end.last
  end

  PRACTICE_END_REASONS = StrictHash.new({
    1 => :retirement,
    2 => :leave,
    3 => :move_away,
    4 => :death
  })

  def practice_end_reason
    PRACTICE_END_REASONS[practice_end_reason_key]
  end

  PRACTICE_ENDED_REASONS = StrictHash.new({
    retirement: "retired",
    leave: "went on leave",
    move_away: "moved away",
    death: "is deceased"
  })

  PRACTICE_ENDED_REASONS.each do |_practice_end_reason, _practice_ended_reason|
    define_method "#{_practice_ended_reason.gsub(" ", "_")}?" do
      practice_end_scheduled &&
        practice_end_reason == _practice_end_reason &&
        practice_end_date < Date.current &&
        (!practice_restart_scheduled? || practice_restart_date >= Date.current)
    end
  end

  def practice_ended_reason
    PRACTICE_ENDED_REASONS[practice_end_reason]
  end

  PRACTICE_ENDING_REASONS = StrictHash.new({
    retirement: "retiring",
    leave: "going on leave",
    move_away: "moving away",
    death: "data entry error"
  })

  PRACTICE_ENDING_REASONS.each do |_practice_end_reason, _practice_ending_reason|
    define_method "#{_practice_ending_reason.gsub(" ", "_")}?" do
      practice_end_scheduled &&
        practice_end_reason == _practice_end_reason &&
        practice_end_date > Date.current
    end
  end

  def practice_ending_reason
    PRACTICE_ENDING_REASONS[practice_ending_reason]
  end

  def referral_icon_key
    if !completed_survey?
      :question_mark
    elsif !practicing?
      :red_x
    elsif practice_ending?
      :orange_warning
    elsif !works_from_offices? || indirect_referrals_only?
      :blue_arrow
    elsif !accepting_new_direct_referrals
      :red_x
    elsif direct_referrals_limited?
      :orange_check
    else
      :green_check
    end
  end

  def practice_ending?
    practice_end_scheduled? && practice_end_date > Date.current
  end

  def indirect_referrals_only?
    !accepting_new_direct_referrals && accepting_new_indirect_referrals?
  end

  def referral_summary
    if !completed_survey?
      "It is unknown whether this specialist is accepting new referrals."
    elsif !practicing?
      not_practicing_details
    elsif practice_ending?
      not_practicing_soon_details
    elsif !works_from_offices?
      "Only works out of #{works_out_of_label}#{referrals_through_label}"
    elsif indirect_referrals_only?
      "Only accepts referrals through #{works_out_of_label}#{referrals_through_label}"
    elsif !accepting_new_direct_referrals?
      "Not accepting new referrals."
    elsif direct_referrals_limited?
      ("Accepting new referrals limited by geography " +
        "or number of patients.")
    else
      "Accepting new referrals."
    end
  end

  def not_practicing_details
    if is_deceased?
      "Deceased."
    elsif retired?
      "Retired."
    elsif moved_away?
      "Moved away."
    elsif went_on_leave?
      if practice_restart_scheduled?
        "On leave until #{practice_restart_date.to_s(:long_ordinal)}."
      else
        "On leave."
      end
    end
  end

  def not_practicing_soon_details
    if going_on_leave?
      if practice_restart_scheduled?
        ("Going on leave from " +
          "#{practice_end_date.to_s(:long_ordinal)} to" +
          " #{practice_restart_date.to_s(:long_ordinal)}.")
      else
        ("Going on leave from " +
          "#{practice_end_date.to_s(:long_ordinal)}.")
      end
    elsif moving_away?
      "Moving away on #{practice_end_date.to_s(:long_ordinal)}."
    elsif retiring?
      "Retiring on #{practice_end_date.to_s(:long_ordinal)}."
    end
  end

  def practicing?
    !practice_end_scheduled ||
      practice_end_date > Date.current ||
      practice_restart_scheduled? && practice_restart_date < Date.current
  end

  def referrals_through_label
    if open_clinics.none? && hospitals.none?
      _returning = "."
    else
      _returning = ". For referral information please see the "

      if open_clinics.one? && hospitals.none?
        _returning += "profile for this clinic."
      elsif hospitals.one? && open_clinics.none?
        _returning += "profile for this hospital."
      elsif hospitals.many? && open_clinics.none?
        _returning += "profiles for these hospitals."
      elsif open_clinics.many? && hospitals.none?
        _returning += "profiles for these clinics."
      else
        _returning += "profiles for these hospitals and clinics."
      end
    end

    _returning
  end

  def works_out_of_label
    if open_clinics.none? && hospitals.none?
      "hospitals or clinics"
    elsif open_clinics.one? && hospitals.none?
      "a clinic"
    elsif hospitals.one? && open_clinics.none?
      "a hospital"
    elsif hospitals.many? && open_clinics.none?
      "hospitals"
    elsif open_clinics.many? && hospitals.none?
      "clinics"
    else
      "hospitals and clinics"
    end
  end

  def show_waittimes?
    works_from_offices? && accepting_new_direct_referrals?
  end

  BOOLEAN_HASH = {
    1 => "Yes",
    2 => "No",
    3 => "Didn't answer",
  }

  def patient_can_book?
    patient_can_book_mask == 1
  end

  def name
    if goes_by_name.present?
      "#{goes_by_name} (#{firstname}) #{lastname}"
    else
      "#{firstname} #{lastname}"
    end
  end

  def formal_name
    if specializations.none? || specializations.any?(&:members_are_physicians?)
      "Dr. #{lastname}"
    else
      name
    end
  end

  SEX_LABELS = {
    1 => "Male",
    2 => "Female",
    3 => "Didn't answer",
  }

  def sex
    Specialist::SEX_LABELS[sex_mask]
  end

  def male?
    sex_mask == 1
  end

  def female?
    sex_mask == 2
  end

  def sex?
    sex_mask != 3
  end

  def padded_billing_number
    if billing_number.present?
      "%05d" % billing_number
    else
      billing_number
    end
  end

  def accepts_referrals_via
    if referral_phone && referral_fax && referral_other_details.present?
      output = "phone, fax, or #{referral_other_details}"
    elsif referral_phone && referral_fax
      output = "phone or fax."
    elsif referral_phone
      if referral_other_details.present?
        output = "phone or #{referral_other_details}"
      else
        output = "phone."
      end
    elsif referral_fax
      if referral_other_details.present?
        output = "fax or #{referral_other_details}"
      else
        output = "fax."
      end
    elsif referral_other_details.present?
      output = referral_other_details.punctuate
    else
      output = ""
    end

    if referral_clinic.present?
      through = "through <a class='ajax' "\
        "href='/clinics/#{referral_clinic.id}'>#{referral_clinic.name}</a>"
      output = output.blank? ? through : "#{through}, or #{output}"
    end
    if referral_details.present?
      return "#{output.punctuate} #{referral_details.convert_newlines_to_br.punctuate}".
        html_safe
    else
      return output.punctuate
    end
  end

  def responds_to
    if respond_to_patient
      if !respond_by_phone && !respond_by_fax && !respond_by_mail
        return "patient"
      else
        return "GP and patient"
      end
    elsif !respond_by_phone && !respond_by_fax && !respond_by_mail
      return "GP or patient"
    else
      return "GP"
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
      return "directly contacting the patient."
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
        return output.punctuate
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
      return "#{output.punctuate} #{urgent_details.convert_newlines_to_br.punctuate}".
        html_safe
    else
      return output.punctuate
    end
  end

  def opened_recently?
    specialist_offices.reject{ |so| !so.opened_recently? }.present?
  end

  def open_saturday?
    specialist_offices.reject{ |so| !so.open_saturday }.present?
  end

  def open_sunday?
    specialist_offices.reject{ |so| !so.open_sunday }.present?
  end

  def day_ids
    {
      6 => open_saturday?,
      7 => open_sunday?
    }.select{ |key, value| value }.keys
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

  def suffix
    if is_gp?
      "GP"
    elsif is_internal_medicine?
      "Int Med"
    elsif sees_only_children?
      "Ped"
    else
      specializations.map(&:suffix).select(&:present?).first || ""
    end
  end

  def ordered_specialist_offices
    @ordered_specialist_offices ||= specialist_offices.sort_by do |office|
      [ (office.has_data? ? 0 : 1), ( office.created_at || DateTime.now ) ]
    end
  end

  def non_empty_offices
    @non_empty_offices ||= specialist_offices.reject(&:empty?)
  end

  def print_clinic_info?
    valid_clinic_locations.any? &&
      (!works_from_offices? || !accepting_new_direct_referrals?)
  end

  def valid_clinic_locations
    @valid_clinic_locations = clinic_locations.reject(&:empty?)
  end

  def hospitals_with_offices_in
    direct = specialist_offices.
      select(&:has_data?).
      map(&:location).
      reject(&:nil?).
      select(&:in_hospital?).
      map(&:hospital_in).
      reject(&:nil?)

    through_clinic = specialist_offices.
      select(&:has_data?).
      map(&:location).
      reject(&:nil?).
      select(&:in_clinic?).
      map(&:location_in).
      reject(&:nil?).
      select(&:in_hospital?).
      map(&:hospital_in).
      reject(&:nil?)

    (direct + through_clinic).uniq
  end

  def open_clinics
    @open_clinics ||= clinics.select(&:open?)
  end

  WORKS_FROM_OFFICES_OPTIONS = [
    ["Offices", true],
    ["Hospitals or clinics only", false]
  ]

private

  def destroy_photo?
    self.photo.clear if @photo_delete == "1"
  end

end
