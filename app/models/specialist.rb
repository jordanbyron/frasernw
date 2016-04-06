class Specialist < ActiveRecord::Base
  include PaperTrailable
  include Reviewable
  include Feedbackable
  include Historical
  include Noteable
  include ProcedureSpecializable
  include Referrable
  include TokenAccessible
  include ApplicationHelper

  attr_accessible :firstname,
    :lastname,
    :goes_by_name,
    :sex_mask,
    :categorization_mask,
    :billing_number,
    :is_gp,
    :is_internal_medicine,
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
    :review_object

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
  has_many :favorite_users,
    through: :favorites,
    source: :user,
    class_name: "User"

  # has many contacts - dates and times they were contacted
  has_many  :contacts

  # dates and times they looked at and changed their own record
  has_many  :views
  has_many  :edits

  MAX_OFFICES = 4
  has_many :specialist_offices, dependent: :destroy
  has_many :offices, through: :specialist_offices

  # TODO: remove
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
    bucket: Pathways::S3.bucket_name(:specialist_photos),
    s3_protocol: :https,
    s3_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }

  validates_attachment_content_type :photo, content_type: /image/
  validates_attachment_size :photo, less_than: 2.megabytes

  before_save :destroy_photo?

  after_commit :flush_cache_for_record
  after_touch :flush_cache_for_record

  scope :deceased, -> { where(status_mask: STATUS_MASK_DECEASED) }

  has_many :review_items,
    polymorphic: true,
    as: :item

  def self.complete_in(specialization)
    in_cities(specialization.complete_cities)
  end

  def specialization_options
    SpecializationOption.
      where(division_id: divisions.map(&:id)).
      where(specialization_id: specialization.map(&:id))
  end

  def complete
    specialization_options.in_progress.none?
  end

  def in_progress
    specialization_options.in_progress.any?
  end

  def self.with_cities
    includes({
      :hospitals => { location: {address: :city}},
      :offices => {location: [
        {:address => :city},
        {:hospital_in => {:location => { :address => :city}}},
        {:location_in => [
          {:address => :city},
          {:hospital_in => {:location => { :address => :city}}}
        ]}
      ]},
      :clinics => {
        locations: [
          {address: :city},
          {hospital_in: {location: {address: :city}}},
        ]
      }
    })
  end

  def self.includes_specialization_page
    includes([
      :procedures,
      :specializations,
      :languages,
      { capacities: { procedure_specialization: :procedure }}
    ]).with_cities
  end

  def flush_cache_for_record
    Rails.cache.delete([self.class.name, self.id, "cities"])
    Rails.cache.delete([self.class.name, self.id])
  end

  def self.in_cities(*cities)
    scope = joins(<<-SQL)
      LEFT JOIN specialist_offices
      ON specialists.id = specialist_offices.specialist_id
      INNER JOIN cities AS specialist_office_cities
      ON specialist_offices.city_id = specialist_office_cities.id
      LEFT JOIN attendances
      ON specialists.id = attendances.specialist_id
      INNER JOIN clinic_locations
      ON attendances.clinic_location_id = clinic_locations.id
      INNER JOIN cities AS attending_clinic_location_cities
      ON clinic_locations.city_id = attending_clinic_location_cities.id
      LEFT JOIN privileges
      ON specialists.id = privileges.specialist_id
      INNER JOIN hospitals
      ON privileges.hospital_id = hospitals.id
      INNER JOIN cities AS privileges_at_hospital_cities
      ON hospital.city_id = privileges_at_hospital_cities.id
    SQL

    # if they have offices use them
    # or else use privileges + attendances

    # TODO experiment with this
    city_ids = cities.map(&:id).sort
    scope.where(<<-SQL, city_ids, city_ids, city_ids)
      (specialist_office_cities.id IS NULL AND
        (attending_clinic_location_cities.id IN (?) OR
          privileges_at_hospital_cities.id IN (?))) OR
      (specialist_office_cities.id IN (?))
    SQL
  end

  def in_specialization(specialization)
    joins("specialist_specializations ON specialists.id = specialist_specializations.specialist_id").
      where("specialist_specializations.id = (?)", specialization.id)
  end

  def self.in_cities_and_specialization(cities, specialization)
    in_cities(cities).in_specialization(specialization)
  end

  def self.in_local_referral_area(division, specialization)
    in_divisions(division).in_specialization(specialization)
  end

  def self.in_divisions(*divisions)
    self.in_cities(
      divisions.map(&:cities).flatten.uniq
    )
  end

  def self.no_division
    self.all - self.in_divisions(*Division.all)
  end

  # performs procedures that are attached to the other specialization without
  # performing them through that specialization
  def self.performs_procedures_in(specialization)
    joins(<<-SQL).where('"ps2".specialization_id = (?)', specialization.id)
      INNER JOIN "capacities"
      ON "capacities".specialist_id = "specialists".id
      INNER JOIN "procedure_specializations" AS "ps1"
      ON "ps1".id = "capacities".procedure_specialization_id
      INNER JOIN "procedure_specializations" AS "ps2"
      ON "ps2".procedure_id = "ps1".procedure_id
    SQL
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

  def locations
    @locations ||= specialist_offices + hospitals + clinic_locations
  end

  def has_offices?
    specialist_offices.select(&:has_data?).any?
  end

  def cities(force: false)
    Rails.cache.fetch([self.class.name, self.id, "cities"], force: force) do
      if has_offices?
        specialist_offices.map(&:city).reject(&:blank?).uniq
      else
        (hospitals.map(&:city) + clinic_locations.map(&:city)).
          reject(&:blank?).
          uniq
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

  def owners
    from_options = specialization_options.map(&:owner?).uniq
    from_options.any? ? from_options : [ default_owner ]
  end

  def hospital_or_clinic_only?
    categorization_mask == 3
  end

  def hospital_or_clinic_referrals_only?
    categorization_mask == 5
  end

  def show_in_table?
    available?
  end

  def available
    availability == 13
  end

  def show_wait_time_in_table?
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
    (retired? || moved_away? || permanently_unavailable?) &&
      (unavailable_from <= (Date.current - 2.years))
  end

  AVAILABILITY = {
    4 => :retired,
    8 => :indefinitely_unavailable,
    7 => :unknown,
    9 => :permanently_unavailable,
    10 => :moved_away,
    12 => :deceased,
    13 => :available,
    14 => :temporarily_unavailable
  }

  AVAILABILITY.values.except(:unknown).each do |value|
    define_method "#{value}?" do
      availability == AVAILABILITY.key(value)
    end
  end

  def status
    if retired?
      "Retired"
    elsif retiring?
      "Retiring as of #{unavailable_from.to_s(:long_ordinal)}"
    elsif status_mask == 6
      if (unavailable_to < Date.current)
        #inavailability date has passed, available again
        Specialist::STATUS_HASH[1]
      else
        "Unavailable from #{unavailable_from.to_s(:long_ordinal)} through #{unavailable_to.to_s(:long_ordinal)}"
      end
    elsif status_mask == 7 || status_mask.blank?
      "It is unknown if this specialist is accepting new patients (the office didn't respond)"
    else
      Specialist::STATUS_HASH[status_mask]
    end
  end

  STATUS_CLASS_AVAILABLE    =
  STATUS_CLASS_LIMITATIONS  =
  STATUS_CLASS_UNAVAILABLE  =
  STATUS_CLASS_WARNING      =
  STATUS_CLASS_UNKNOWN      =
  STATUS_CLASS_EXTERNAL     =
  STATUS_CLASS_BLANK        = ""

  #match clinic
  STATUS_CLASS_HASH = {
    STATUS_CLASS_AVAILABLE => 1,
    STATUS_CLASS_EXTERNAL => 2,
    STATUS_CLASS_WARNING => 3,
    STATUS_CLASS_UNAVAILABLE => 4,
    STATUS_CLASS_UNKNOWN => 5,
    STATUS_CLASS_BLANK => 6,
    STATUS_CLASS_LIMITATIONS => 7,
  }

  #match tooltip to status_class
  STATUS_TOOLTIP_HASH = {
    STATUS_CLASS_AVAILABLE   => "Accepting new referrals",
    STATUS_CLASS_LIMITATIONS => "Accepting limited new referrals by geography or # of patients",
    STATUS_CLASS_UNAVAILABLE => ,
    STATUS_CLASS_WARNING     => "Referral status will change soon",
    STATUS_CLASS_UNKNOWN     => "Referral status is unknown",
    STATUS_CLASS_EXTERNAL    => "Only works out of, and possibly accepts referrals through, clinics and/or hospitals",
    STATUS_CLASS_BLANK       => ""
  }

  def referral_status_icon_classes
    if not_responded? || availability_unknown?
      "icon-question-sign"
    elsif !surveyed?
      ""
    elsif available? && indirect_referrals_only?
      "icon-signout icon-blue"
    elsif available? && accepting_new_referrals? && referrals_limited?
      "icon-ok icon-orange"
    elsif available? && accepting_new_referral? && (temporarily_unavailable_soon? || retiring_soon?)
      "icon-warning-sign icon-orange"
    elsif available? && accepting_new_referrals?
      "icon-ok icon-green"
    elsif !available? || !accepting_new_referrals?
      "icon-remove icon-red"
    else
      "catch this"
    end
  end

  def referral_status_label
    if not_responded? || availability_unknown?
      "Referral status is unknown"
    elsif !surveyed?
      ""
    elsif available? && indirect_referrals_only? && accepting_new_referrals?
      if attendances.any? && privileges.any?
        "Only accepts referrals through clinics and hospitals."
      elsif attendances.any?
        "Only accepts referrals through clinics."
      elsif privileges.any?
        "Only accepts referrals through clinics hospitals."
      else
        ""
      end
    elsif available? && indirect_referrals_only? && accepting_new_referrals == nil
      # Former "Only works out of hospitals and clinics" specialists
      # Hopefully we can gather this information and delete this branch
      if attendances.any? && privileges.any?
        "Only works out of, and possibly accepts referrals through clinics and hospitals."
      elsif attendances.any?
        "Only works out of, and possibly accepts referrals through clinics."
      elsif privileges.any?
        "Only works out of, and possibly accepts referrals through hospitals."
      else
        ""
      end
    elsif available? && accepting_new_referrals? && referrals_limited?
      "Accepting limited new referrals by geography or number of patients"
    elsif available? && accepting_new_referrals? && (temporarily_unavailable_soon? || retiring_soon?)
      "Referral status will change soon"
    elsif available? && accepting_new_referrals?
      "Accepting new referrals"
    elsif !available? || !accepting_new_referrals?
      "Not accepting new referrals"
    else
      "catch this"
    end
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
    # TODO
    status_mask == 2
  end

  def retiring?
    (status_mask == 5) && (unavailable_from > Date.current)
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

  BOOLEAN_LABELS = {
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
    "Dr. #{lastname}"
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
    practise_limitations
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
      through = "through <a class='ajax' href='/clinics/#{referral_clinic.id}'>#{referral_clinic.name}</a>"
      output = output.blank? ? through : "#{through}, or #{output}"
    end
    if referral_details.present?
      return "#{output.punctuate} #{referral_details.convert_newlines_to_br.punctuate}".html_safe
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
    if (not respond_by_phone) && (not respond_by_fax) && (not respond_by_mail) && (not respond_to_patient)
      return ""
    elsif (not respond_by_phone) && (not respond_by_fax) && (not respond_by_mail) && respond_to_patient
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
        return output.capitalize_first_letter + ", and by directly contacting the patient."
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
      return "#{output.punctuate} #{urgent_details.convert_newlines_to_br.punctuate}".html_safe
    else
      return output.punctuate
    end
  end

  def child_procedures(procedure)
    result = []
    procedure.procedure_specializations.each do |ps|
      next if not ps.has_children?
      result += (ProcedureSpecialization.descendants_of(ps) & self.procedure_specializations)
    end
    result.uniq!
    return (result ? result.compact.collect{ |ps| ps.procedure } : [])
  end

  def opened_recently?
    specialist_offices.select(&:opened_recently?).any?
  end

  def open_saturday?
    specialist_offices.select(&:open_saturday?).any?
  end

  def open_sunday?
    specialist_offices.select(&:open_sunday?).any?
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
    if !saved_token
      update_column(:saved_token, SecureRandom.hex(16))
    end

    saved_token
  end

  def label
    name
  end

  def suffix
    if is_gp?
      "GP"
    elsif is_internal_medicine?
      "Int Med"
    else
      specializations.map(&:suffix).select(&:present?).first || ""
    end
  end

  def ordered_specialist_offices
    @ordered_specialist_offices ||= specialist_offices.sort_by do |office|
      [ (office.has_data? ? 0 : 1), ( office.created_at || DateTime.now ) ]
    end
  end

  def visible_specializations(user)
    if user.as_admin_or_super?
      specializations
    else
      complete_specializations(user)
    end
  end

  def complete_specializations(user)
    specializations.complete_in(user.as_divisions)
  end

  def favorited_by?(user)
    if user.authenticated?
      Favorite.find_by(
        user_id: user.id,
        favoritable_id: id,
        favoritable_type: "Specialist"
      ).present?
    else
      false
    end
  end

  def family_practice_only?
    specializations.one? &&
      specializations.include?(Specialization.find_by(name: "Family Practice"))
  end

private

  def destroy_photo?
    self.photo.clear if @photo_delete == "1"
  end

end
