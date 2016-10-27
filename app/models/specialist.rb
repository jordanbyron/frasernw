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

  attr_accessible :firstname,
    :lastname,
    :goes_by_name,
    :sex_mask,
    :categorization_mask,
    :billing_number,
    :is_gp,
    :is_internal_medicine,
    :sees_only_children,
    :practise_limitations,
    :interest,
    :procedure_ids,
    :direct_phone_old,
    :direct_phone_extension_old,
    :red_flags,
    :clinic_location_ids,
    :responds_via,
    :contact_name,
    :contact_email,
    :contact_phone,
    :contact_notes,
    :referral_criteria,
    :status_mask,
    :location_opened_old,
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
    :patient_can_book_old,
    :patient_can_book_mask,
    :lagtime_mask,
    :waittime_mask,
    :referral_form_old,
    :referral_form_mask,
    :unavailable_from,
    :unavailable_to,
    :patient_instructions,
    :cancellation_policy,
    :hospital_clinic_details,
    :interpreter_available,
    :photo,
    :photo_delete,
    :hospital_ids,
    :specialization_ids,
    :capacities_attributes,
    :language_ids,
    :specialist_offices_attributes,
    :admin_notes,
    :referral_forms_attributes,
    :review_object,
    :hidden

  # specialists can have multiple specializations
  has_many :specialist_specializations, dependent: :destroy
  has_many :specializations, through: :specialist_specializations

  # specialists have the capacity to perform procedures
  has_many :capacities, dependent: :destroy

  # we want to be using this generic alias so we can duck type
  # procedure specializables
  has_many :procedure_specialization_links, class_name: "Capacity"
  has_many :procedure_specializations, through: :capacities
  has_many :procedures, through: :procedure_specializations
  accepts_nested_attributes_for :capacities,
    reject_if: lambda { |c| c[:procedure_specialization_id].blank? },
    allow_destroy: true

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
  has_many :favorite_users, through: :favorites, source: :user, class_name: "User"

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

  scope :deceased, -> { where(status_mask: STATUS_MASK_DECEASED) }

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
      { capacities: { procedure_specialization: :procedure } }
    ]).with_cities
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
    cities_for_front_page(force: true)
    ExpireFragment.call(
      Rails.application.routes.url_helpers.specialist_path(self)
    )
  end

  def self.in_cities(c)
  #for specialists that haven't responded or are purosely not yet surveyed we just
  # try to grab any city that makes sense
    city_ids = Array.wrap(c).map{ |city| city.id }.sort

    # responded_* location searches exclude specialist with CATEGORIZATION_3:
    # "Only works out of hospitals or clinics"
    responded_direct = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "Office",
      city_ids,
      [1, 2, 4, 5]
    )

    responded_in_hospital = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "Office",
      "Hospital",
      city_ids,
      [1, 2, 4, 5]
    )

    responded_in_clinic = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "Office",
      "ClinicLocation",
      city_ids,
      [1, 2, 4, 5]
    )

    responded_in_clinic_in_hospital = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "Office",
      "ClinicLocation",
      "Hospital",
      city_ids,
      [1, 2, 4, 5]
    )

    # hoc_* location searches exclude specialists with CATEGORIZATION_1:
    # "Responded to survey"
    hoc_hospital = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "Hospital",
      city_ids,
      [2, 3, 4, 5]
    )

    hoc_clinic = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "ClinicLocation",
      city_ids,
      [2, 3, 4, 5]
    )

    hoc_clinic_in_hospital = joins(
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
        'AND "specialists".categorization_mask IN (?)',
      "ClinicLocation",
      "Hospital",
      city_ids,
      [2, 3, 4, 5]
    )

    (
      responded_direct +
      responded_in_hospital +
      responded_in_clinic +
      responded_in_clinic_in_hospital +
      hoc_hospital +
      hoc_clinic +
      hoc_clinic_in_hospital
    ).uniq
  end

  def self.in_cities_and_specialization(c, specialization)
  # (IGNORE, not used in actual project but may be used)
  # for specialists that haven't responded or are purosely not yet surveyed we just
  # try to grab any city that makes sense
    city_ids = Array.wrap(c).map{ |city| city.id }.sort
    responded_direct = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "addresses" AS "direct_address" '\
        'ON "direct_location".address_id = "direct_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_address".city_id IN (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "direct_location".location_in_id IS NULL '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "Office",
      city_ids,
      [1, 2, 4, 5], specialization.id
    )

    responded_in_hospital = joins(
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
        'ON "hospital_in_location".address_id = "hospital_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "Office",
      "Hospital",
      city_ids,
      [1, 2, 4, 5], specialization.id
    )

    responded_in_clinic = joins(
      'INNER JOIN "specialist_offices" '\
        'ON "specialists"."id" = "specialist_offices"."specialist_id" '\
        'INNER JOIN "offices" '\
        'ON "specialist_offices".office_id = "offices".id '\
        'INNER JOIN "locations" AS "direct_location" '\
        'ON "offices".id = "direct_location".locatable_id '\
        'INNER JOIN "locations" AS "clinic_location" '\
        'ON "clinic_location".id = "direct_location".location_in_id '\
        'INNER JOIN "addresses" AS "clinic_address" '\
        'ON "clinic_location".address_id = "clinic_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "clinic_location".locatable_type = (?) '\
        'AND "clinic_location".hospital_in_id IS NULL '\
        'AND "clinic_address".city_id IN (?) '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "Office",
      "ClinicLocation",
      city_ids,
      [1, 2, 4, 5], specialization.id
    )

    responded_in_clinic_in_hospital = joins(
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
        'ON "hospital_in_location".address_id = "hospital_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"direct_location".locatable_type = (?) '\
        'AND "direct_location".hospital_in_id IS NULL '\
        'AND "clinic_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "Office",
      "ClinicLocation",
      "Hospital",
      city_ids,
      [1, 2, 4, 5], specialization.id
    )

    hoc_hospital = joins(
      'INNER JOIN "privileges" '\
        'ON "specialists"."id" = "privileges"."specialist_id" '\
        'INNER JOIN "hospitals" '\
        'ON "privileges".hospital_id = "hospitals".id '\
        'INNER JOIN "locations" AS "hospital_in_location" '\
        'ON "hospitals".id = "hospital_in_location".locatable_id '\
        'INNER JOIN "addresses" AS "hospital_address" '\
        'ON "hospital_in_location".address_id = "hospital_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "Hospital",
      city_ids,
      [2, 3, 4, 5], specialization.id
    )

    hoc_clinic = joins(
      'INNER JOIN "attendances" '\
        'ON "specialists"."id" = "attendances"."specialist_id" '\
        'INNER JOIN "clinic_locations" AS "clinic_in_clinic_location" '\
        'ON "clinic_in_clinic_location".id = "attendances".clinic_location_id '\
        'INNER JOIN "locations" AS "clinic_in_location" '\
        'ON "clinic_in_location".locatable_id = "clinic_in_clinic_location".id '\
        'INNER JOIN "addresses" AS "clinic_address" '\
        'ON "clinic_in_location".address_id = "clinic_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"clinic_in_location".locatable_type = (?) '\
        'AND "clinic_address".city_id IN (?) '\
        'AND "clinic_in_location".hospital_in_id IS NULL '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "ClinicLocation",
      city_ids,
      [2, 3, 4, 5], specialization.id
    )

    hoc_clinic_in_hospital = joins(
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
        'ON "hospital_in_location".address_id = "hospital_address".id '\
        'INNER JOIN "specialist_specializations" '\
        'ON "specialist_specializations".specialist_id = "specialists".id'
    ).where(
      '"clinic_location".locatable_type = (?) '\
        'AND "hospital_in_location".locatable_type = (?) '\
        'AND "hospital_address".city_id IN (?) '\
        'AND "specialists".categorization_mask IN (?) '\
        'AND "specialist_specializations".specialization_id = (?)',
      "ClinicLocation",
      "Hospital",
      city_ids,
      [2, 3, 4, 5], specialization.id
    )

    (
      responded_direct +
      responded_in_hospital +
      responded_in_clinic +
      responded_in_clinic_in_hospital +
      hoc_hospital +
      hoc_clinic +
      hoc_clinic_in_hospital
    ).uniq
  end

  def self.in_divisions(divisions)
    divs = Array.wrap(divisions)

    self.in_cities(divs.map{ |division| division.cities }.flatten.uniq)
  end

  def self.no_division
    @_specialist_no_division ||= self.all - self.in_divisions(Division.all)
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

  def self.filter(specialists, filter)
    specialists.select do |specialist|
      specialist.divisions.include? filter[:division]
    end
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

  def city
    if responded? || hospital_or_clinic_only? || hospital_or_clinic_referrals_only?
      cities.first
    else
      nil
    end
  end

  def cities(force: false)
    Rails.cache.fetch([self.class.name, self.id, "cities"], force: force) do
      if responded?
        offices.map(&:city).reject(&:blank?).uniq
      elsif hospital_or_clinic_only?
        (
          hospitals.map(&:city) +
          clinic_locations.map(&:city)
        ).flatten.reject(&:blank?).uniq
      elsif (
        not_responded? ||
        purposely_not_yet_surveyed? ||
        hospital_or_clinic_referrals_only?
      )
        (
          offices.map(&:city) +
          hospitals.map(&:city) +
          clinic_locations.map(&:city)
        ).flatten.reject(&:blank?).uniq
      else
        []
      end
    end
  end

  #we need to know their 'old' cities if they moved away
  def cities_for_front_page(force: false)
    Rails.cache.fetch(
      [self.class.name, self.id, "cities_for_front_page"],
      force: force
    ) do
      if moved_away?
        offices.map(&:city).reject(&:blank?).uniq
      else
        cities
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

  CATEGORIZATION_LABELS = {
    1 => "Responded to survey",
    2 => "Not responded to survey",
    3 => "Only works out of hospitals or clinics",
    4 => "Purposely not yet surveyed",
    5 => "Only accepts referrals through hospitals or clinics"
  }

  def responded?
    categorization_mask == 1
  end

  def not_responded?
    categorization_mask == 2
  end

  def hospital_or_clinic_only?
    categorization_mask == 3
  end

  def purposely_not_yet_surveyed?
    categorization_mask == 4
  end

  def hospital_or_clinic_referrals_only?
    categorization_mask == 5
  end

  def show_in_table?
    not_responded? ||
    hospital_or_clinic_only? ||
    hospital_or_clinic_referrals_only? ||
    (responded? && !unavailable_for_a_while?)
  end

  def show_waittimes?
    responded? &&
      (
        accepting_new_patients? ||
        retiring? ||
        accepting_with_limitations? ||
        (
          status_mask == 6 &&
          (unavailable_to < Date.current || unavailable_from > Date.current)
        )
      )
  end

  def not_available?
    retired? || permanently_unavailable? || moved_away?
  end

  def unavailable_for_a_while?
    (
      retired? || moved_away? || permanently_unavailable?) &&
      (unavailable_from <= (Date.current - 2.years)
    )
  end

  def again_available?
    (status_mask == 6) && (unavailable_to < Date.current)
  end

  STATUS_HASH = {
    1 => "Accepting new referrals",
    11 => "Accepting limited new referrals by geography or # of patients",
    2 => "Not accepting new referrals",
    4 => "Retired as of",
    5 => "Retiring as of",
    6 => "Unavailable between",
    8 => "Indefinitely unavailable",
    9 => "Permanently unavailable",
    12 => "Deceased",
    10 => "Moved away",
    7 => "Didn't answer"
  }

  def status
    if retired?
      "Retired"
    elsif retiring?
      "Retiring as of #{unavailable_from.to_s(:long_ordinal)}"
    elsif status_mask == 6
      if again_available?
        Specialist::STATUS_HASH[1]
      else
        "Unavailable from #{unavailable_from.to_s(:long_ordinal)} through "\
          "#{unavailable_to.to_s(:long_ordinal)}"
      end
    elsif status_mask == 7 || status_mask.blank?
      "It is unknown if this specialist is accepting new patients "\
        "(the office didn't respond)"
    else
      Specialist::STATUS_HASH[status_mask]
    end
  end

  STATUS_CLASS_AVAILABLE    = "icon-ok icon-green"
  STATUS_CLASS_LIMITATIONS  = "icon-ok icon-orange"
  STATUS_CLASS_UNAVAILABLE  = "icon-remove icon-red"
  STATUS_CLASS_WARNING      = "icon-warning-sign icon-orange"
  STATUS_CLASS_UNKNOWN      = "icon-question-sign"
  STATUS_CLASS_EXTERNAL     = "icon-signout icon-blue"
  STATUS_CLASS_BLANK        = ""

  # match clinic
  STATUS_CLASS_HASH = {
    STATUS_CLASS_AVAILABLE => 1,
    STATUS_CLASS_EXTERNAL => 2,
    STATUS_CLASS_WARNING => 3,
    STATUS_CLASS_UNAVAILABLE => 4,
    STATUS_CLASS_UNKNOWN => 5,
    STATUS_CLASS_BLANK => 6,
    STATUS_CLASS_LIMITATIONS => 7,
  }

  # match tooltip to status_class
  STATUS_TOOLTIP_HASH = {
    STATUS_CLASS_AVAILABLE   => "Accepting new referrals",
    STATUS_CLASS_LIMITATIONS => "Accepting limited new referrals by geography "\
                                "or # of patients",
    STATUS_CLASS_UNAVAILABLE => "Not accepting new referrals",
    STATUS_CLASS_WARNING     => "Referral status will change soon",
    STATUS_CLASS_UNKNOWN     => "Referral status is unknown",
    STATUS_CLASS_EXTERNAL    => "Only works out of, and possibly accepts "\
                                "referrals through, clinics and/or hospitals",
    STATUS_CLASS_BLANK       => ""
  }

  def status_class
    # purposely handle categorization prior to status
    if not_responded?
      return STATUS_CLASS_UNKNOWN
    elsif purposely_not_yet_surveyed?
      return STATUS_CLASS_BLANK
    elsif hospital_or_clinic_only? || hospital_or_clinic_referrals_only?
      return STATUS_CLASS_EXTERNAL
    elsif accepting_with_limitations?
      return STATUS_CLASS_LIMITATIONS
    elsif accepting_new_patients? || again_available?
      return STATUS_CLASS_AVAILABLE
    elsif (
      follow_up_only? ||
      retired? ||
      (
        (status_mask == 6) && (unavailable_from <= Date.current) &&
        (unavailable_to >= Date.current)
      ) ||
      indefinitely_unavailable? ||
      permanently_unavailable? ||
      deceased? ||
      moved_away?
    )
      # only seeing old patients, retired, "retiring as of" date has passed",
      # or in midst of unavailability, indefinitely unavailable, permanently
      # unavailable, or moved away
      return STATUS_CLASS_UNAVAILABLE
    elsif (retiring? || ((status_mask == 6) && (unavailable_from > Date.current)))
      return STATUS_CLASS_WARNING
    elsif ((status_mask == 3) || (status_mask == 7) || status_mask.blank?)
      return STATUS_CLASS_UNKNOWN
    else
      #this shouldn't really happen
      return STATUS_CLASS_BLANK
    end
  end

  def status_class_hash
    STATUS_CLASS_HASH[status_class]
  end

  def status_tooltip
    STATUS_TOOLTIP_HASH[status_class]
  end

  def accepting_new_patients?
    status_mask == 1
  end

  def accepting_with_limitations?
    status_mask == 11
  end

  def follow_up_only?
    status_mask == 2
  end

  def retired?
    (status_mask == 4) || ((status_mask == 5) && (unavailable_from <= Date.current))
  end

  def retiring?
    (status_mask == 5) && (unavailable_from > Date.current)
  end

  def indefinitely_unavailable?
    status_mask == 8
  end

  def permanently_unavailable?
    status_mask == 9
  end

  def moved_away?
    status_mask == 10
  end

  STATUS_MASK_DECEASED = 12
  def deceased?
    status_mask == STATUS_MASK_DECEASED
  end

  WAITTIME_LABELS = {
    1 => "Within one week",
    2 => "1-2 weeks",
    3 => "2-4 weeks",
    4 => "1-2 months",
    5 => "2-4 months",
    6 => "4-6 months",
    7 => "6-9 months",
    8 => "9-12 months",
    9 => "12-18 months",
    10 => "18-24 months",
    11 => "2-2.5 years",
    12 => "2.5-3 years",
    13 => ">3 years"
  }

  def waittime
    waittime_mask.present? ? Specialist::WAITTIME_LABELS[waittime_mask] : ""
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
    Specialist::LAGTIME_LABELS[lagtime_mask]
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

  def practice_limitations
    return practise_limitations
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

  def child_procedures(procedure)
    result = []
    procedure.procedure_specializations.each do |ps|
      next if not ps.has_children?
      result += (
        ProcedureSpecialization.descendants_of(ps) & self.procedure_specializations
      )
    end
    result.uniq!
    return (result ? result.compact.collect{ |ps| ps.procedure } : [])
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

  def print_clinic_info?
    valid_clinic_locations.any? &&
    (hospital_or_clinic_only? || hospital_or_clinic_referrals_only?)
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

private

  def destroy_photo?
    self.photo.clear if @photo_delete == "1"
  end

end
