class Specialist < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :firstname, :lastname, :goes_by_name, :sex_mask, :categorization_mask, :billing_number, :practise_limitations, :interest, :procedure_ids, :direct_phone_old, :direct_phone_extension_old, :red_flags, :clinic_ids, :responds_via, :contact_name, :contact_email, :contact_phone, :contact_notes, :referral_criteria, :status_mask, :location_opened, :referral_fax, :referral_phone, :referral_clinic_id, :referral_other_details, :referral_details, :urgent_fax, :urgent_phone, :urgent_other_details, :urgent_details, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :status_details, :required_investigations, :not_performed, :patient_can_book_old, :patient_can_book_mask, :lagtime_mask, :waittime_mask, :referral_form_old, :referral_form_mask, :unavailable_from, :unavailable_to, :patient_instructions, :cancellation_policy, :hospital_clinic_details, :interpreter_available, :photo, :photo_delete, :address_update, :hospital_ids, :specializations_including_in_progress_ids, :capacities_attributes, :language_ids, :user_controls_specialist_offices_attributes, :specialist_offices_attributes, :admin_notes, :referral_forms_attributes
  has_paper_trail ignore: [:saved_token, :review_item]
  
  # specialists can have multiple specializations
  has_many :specialist_specializations, :dependent => :destroy
  has_many :specializations, :through => :specialist_specializations, :conditions => { "in_progress" => false }
  has_many :specializations_including_in_progress, :through => :specialist_specializations, :source => :specialization, :class_name => "Specialization"

  # specialists have the capacity to perform procedures
  has_many   :capacities, :dependent => :destroy
  has_many   :procedure_specializations, :through => :capacities
  has_many   :procedures, :through => :procedure_specializations
  accepts_nested_attributes_for :capacities, :reject_if => lambda { |c| c[:procedure_specialization_id].blank? }, :allow_destroy => true
  
  # specialists attend clinics
  has_many   :attendances, :dependent => :destroy
  has_many   :clinics, :through => :attendances
  
  # specialists have "priviliges" at hospitals
  has_many   :privileges, :dependent => :destroy
  has_many   :hospitals, :through => :privileges
  
  # specialists "speak" many languages
  has_many   :specialist_speaks, :dependent => :destroy
  has_many   :languages, :through => :specialist_speaks
  
  #specialists have multiple referral forms
  has_many   :referral_forms, :as => :referrable, :dependent => :destroy
  accepts_nested_attributes_for :referral_forms, :allow_destroy => true
  
  # specialists are favorited by users of the system
  has_many   :favorites
  has_many   :favorite_users, :through => :favorites, :source => :user, :class_name => "User"

  # has many contacts - dates and times they were contacted
  has_many  :contacts

  # dates and times they looked at and changed their own record
  has_many  :views
  has_many  :edits
  
  has_one :review_item, :as => :item, :conditions => { "archived" => false }
  has_many :archived_review_items, :as => :item, :foreign_key => "item_id", :class_name => "ReviewItem"
  
  has_many :feedback_items, :as => :item, :conditions => { "archived" => false }
  has_many :archived_feedback_items, :as => :item, :foreign_key => "item_id", :class_name => "FeedbackItem"
  
  MAX_OFFICES = 3
  has_many :specialist_offices, :dependent => :destroy
  has_many :offices, :through => :specialist_offices
  has_many :locations, :through => :offices
  accepts_nested_attributes_for :specialist_offices
  
  #specialist are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_specialist_offices, :through => :specialist_offices
  has_many :controlling_users, :through => :user_controls_specialist_offices, :source => :user, :class_name => "User"
  accepts_nested_attributes_for :user_controls_specialist_offices, :reject_if => lambda { |ucso| ucso[:user_id].blank? }, :allow_destroy => true
  
  has_attached_file :photo,
    :styles => { :thumb => "200x200#" },
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME_SPECIALIST_PHOTOS'],
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  
  before_save :destroy_photo?
  
  def self.in_cities(cities)
    city_ids = cities.map{ |city| city.id }
    direct = joins('INNER JOIN "specialist_offices" ON "specialists"."id" = "specialist_offices"."specialist_id" INNER JOIN "offices" ON "specialist_offices".office_id = "offices".id INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "addresses" AS "direct_address" ON "direct_location".address_id = "direct_address".id').where('"direct_location".locatable_type = "Office" AND "direct_address".city_id in (?) AND "direct_location".hospital_in_id IS NULL', city_ids)
    in_hospital = joins('INNER JOIN "specialist_offices" ON "specialists"."id" = "specialist_offices"."specialist_id" INNER JOIN "offices" ON "specialist_offices".office_id = "offices".id INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "hospitals" ON "hospitals".id = "direct_location".hospital_in_id INNER JOIN "locations" AS "hospital_in_location" ON "hospitals".id = "hospital_in_location".locatable_id INNER JOIN "addresses" AS "hospital_address" ON "hospital_in_location".address_id = "hospital_address".id').where('"direct_location".locatable_type = "Office" AND "hospital_in_location".locatable_type = "Hospital" AND "hospital_address".city_id in (?)', city_ids)
    in_clinic = joins('INNER JOIN "specialist_offices" ON "specialists"."id" = "specialist_offices"."specialist_id" INNER JOIN "offices" ON "specialist_offices".office_id = "offices".id INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "clinics" ON "clinics".id = "direct_location".clinic_in_id INNER JOIN "locations" AS "clinic_in_location" ON "clinics".id = "clinic_in_location".locatable_id INNER JOIN "addresses" AS "clinic_address" ON "clinic_in_location".address_id = "clinic_address".id').where('"direct_location".locatable_type = "Office" AND "direct_location".hospital_in_id IS NULL AND "clinic_in_location".locatable_type = "Clinic" AND "clinic_in_location".hospital_in_id IS NULL AND "clinic_address".city_id in (?)', city_ids)
    in_clinic_in_hospital = joins('INNER JOIN "specialist_offices" ON "specialists"."id" = "specialist_offices"."specialist_id" INNER JOIN "offices" ON "specialist_offices".office_id = "offices".id INNER JOIN "locations" AS "direct_location" ON "offices".id = "direct_location".locatable_id INNER JOIN "clinics" ON "clinics".id = "direct_location".clinic_in_id INNER JOIN "locations" AS "clinic_in_location" ON "clinics".id = "clinic_in_location".locatable_id INNER JOIN "hospitals" ON "clinic_in_location".hospital_in_id = "hospitals".id INNER JOIN "locations" AS "hospital_in_location" ON "hospitals".id = "hospital_in_location".locatable_id INNER JOIN "addresses" AS "hospital_address" ON "hospital_in_location".address_id = "hospital_address".id').where('"direct_location".locatable_type = "Office" AND "direct_location".hospital_in_id IS NULL AND "clinic_in_location".locatable_type = "Clinic" AND "hospital_in_location".locatable_type = "Hospital" AND "hospital_address".city_id in (?)', city_ids)
    (direct + in_hospital + in_clinic + in_clinic_in_hospital).uniq
  end
  
  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end
  
  def photo_delete
    @photo_delete ||= "0"
  end
  
  def photo_delete=(value)
    @photo_delete = value
  end
  
  validates_attachment_content_type :photo, :content_type => /image/
  validates_attachment_size :photo, :less_than => 2.megabytes
  
  default_scope order('specialists.lastname, specialists.firstname')
  
  #clinic that referrals are done through
  belongs_to :referral_clinic, :class_name => "Clinic"
  
  def city
    o = offices.first
    return nil if o.blank?
    return o.city
  end
  
  def cities
    if responded?
      offices.map{ |o| o.city }.reject{ |c| c.blank? }.uniq
    elsif hospital_or_clinic_only?
      (hospitals.map{ |h| h.city } + clinics.map{ |c| c.city }).reject{ |i| i == nil }.uniq
    else
      []
    end
  end
  
  def divisions
    return cities.map{ |city| city.divisions }.flatten.uniq
  end
  
  def owner_for_divisions(input_divisions)
    if specializations.blank? || divisions.blank?
      return default_owner
    elsif input_divisions.present?
      #interesect the passed in divisions with the divisions the specialist is in, to find a match
      intersecting_divisions = input_divisions & divisions
      if intersecting_divisions.present?
        specialization_owners = []
        specializations.each{ |specialization| specialization_owners << specialization.specialization_owners.for_division(intersecting_divisions.first) }
        specialization_owners.flatten!
        if specialization_owners.first.present? && specialization_owners.first.owner.present?
          return specialization_owners.first.owner
        end
      end
    end
    
    #We either didn't pass in a division, or the interesection was blank with the specialist's actual divisions.
    #So just return the owner for the clinic's division
    divisions.each do |division|
      specializations.specialization_owners.for_division(division).each do |specialization_owner|
        if specialization_owner.owner.present?
          return specialization_owner.owner
        end
      end
    end
    
    #There is no owner for the any of the specializations this specialist is in...
    return default_owner
  end
  
  CATEGORIZATION_HASH = {
    1 => "Responded to survey",
    2 => "Not responded to survey",
    3 => "Only works out of hospitals or clinics",
    4 => "Purposely not yet surveyed",
    5 => "Moved away"
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
  
  def moved_away?
    categorization_mask == 5
  end
  
  def show_in_table?
    responded? || not_responded? || hospital_or_clinic_only?
  end
  
  def disabled_in_table?
    not_responded?
  end
  
  STATUS_HASH = { 
    1 => "Accepting new patients", 
    2 => "Only doing follow up on previous patients", 
    4 => "Retired as of",
    5 => "Retiring as of",
    6 => "Unavailable between",
    8 => "Indefinitely unavailable",
    7 => "Didn't answer"
  }
  
  def status
    if status_mask == 4 
      "Retired"
    elsif status_mask == 5
      if unavailable_from <= Date.today
        #retiring as of date has passed, retired
        "Retired"
      else
        "Retiring as of #{unavailable_from.to_s(:long_ordinal)}"
      end
    elsif status_mask == 6
      if (unavailable_to < Date.today)
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
  
  STATUS_CLASS_AVAILABLE    = "icon-ok icon-green"
  STATUS_CLASS_UNAVAILABLE  = "icon-remove icon-red"
  STATUS_CLASS_WARNING      = "icon-exclamation-sign icon-orange"
  STATUS_CLASS_UNKNOWN      = "icon-question-sign"
  STATUS_CLASS_EXTERNAL     = "icon-signout icon-blue"
  STATUS_CLASS_BLANK        = ""
  
  #match clinic
  STATUS_CLASS_HASH = {
    STATUS_CLASS_AVAILABLE => 1,
    STATUS_CLASS_UNAVAILABLE => 2,
    STATUS_CLASS_WARNING => 3,
    STATUS_CLASS_UNKNOWN => 4,
    STATUS_CLASS_EXTERNAL => 5,
    STATUS_CLASS_BLANK => 6,
  }
  
  def status_class
    if not_responded?
      return STATUS_CLASS_UNKNOWN
    elsif moved_away?
      return STATUS_CLASS_UNAVAILABLE
    elsif purposely_not_yet_surveyed?
      return STATUS_CLASS_BLANK
    elsif hospital_or_clinic_only?
      return STATUS_CLASS_EXTERNAL
    elsif ((status_mask == 1) || ((status_mask == 6) && (unavailable_to < Date.today)))
      #marked as available, or the "unavailable between" period has passed
      return STATUS_CLASS_AVAILABLE
    elsif ((status_mask == 2) || (status_mask == 4) || ((status_mask == 5) && (unavailable_from <= Date.today)) || ((status_mask == 6) && (unavailable_from <= Date.today) && (unavailable_to >= Date.today)) || (status_mask == 8) || moved_away?)
      #only seeing old patients, retired, "retiring as of" date has passed", or in midst of inavailability, indefinitely unavailables, or moved away
      return STATUS_CLASS_UNAVAILABLE
    elsif (((status_mask == 5) && (unavailable_from > Date.today)) || ((status_mask == 6) && (unavailable_from > Date.today)))
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
  
  def accepting_new_patients?
    status_mask == 1
  end
  
  def retired?
    (status_mask == 4) || ((status_mask == 5) && (unavailable_from <= Date.today))
  end
  
  def retiring?
    (status_mask == 5) && (unavailable_from > Date.today)
  end
  
  def opened_this_year?
    location_opened == Time.now.year.to_s
  end
  
  WAITTIME_HASH = { 
    1 => "Within one week", 
    2 => "1-2 weeks", 
    3 => "2-4 weeks", 
    4 => "1-2 months", 
    5 => "2-4 months", 
    6 => "4-6 months", 
    7 => "6-9 months", 
    8 => "9-12 months", 
    9 => "12-18 months", 
    10 => ">18 months"
  }
  
  def waittime
    waittime_mask.present? ? Specialist::WAITTIME_HASH[waittime_mask] : ""
  end
  
  LAGTIME_HASH = { 
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
    11 => ">18 months"
  }
  
  def lagtime
    Specialist::LAGTIME_HASH[lagtime_mask]
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
    "Dr. #{lastname}"
  end
  
  SEX_HASH = { 
    1 => "Male", 
    2 => "Female", 
    3 => "Didn't answer", 
  }
  
  def sex
    Specialist::SEX_HASH[sex_mask]
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
  
  def billing_number_padded
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
      through = "through <a class='ajax' href='/clinics/#{referral_clinic.id}'>#{referral_clinic.name}</a>"
      output = output.blank? ? through : "#{through}, or #{output}"
    end
    if referral_details.present?
      return "#{output.punctuate} #{referral_details.convert_newlines_to_br.punctuate}".html_safe
    else
      return output.punctuate
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
  
  def open_saturday?
    specialist_offices.reject{ |so| !so.open_saturday }.present?
  end
  
  def open_sunday?
    specialist_offices.reject{ |so| !so.open_sunday }.present?
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end

private
  
  def destroy_photo?
    self.photo.clear if @photo_delete == "1"
  end
  
end
