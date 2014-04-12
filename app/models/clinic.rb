class Clinic < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :name, :deprecated_phone, :deprecated_phone_extension, :deprecated_fax, :deprecated_contact_details, :categorization_mask, :deprecated_sector_mask, :deprecated_url, :deprecated_email, :deprecated_wheelchair_accessible_mask, :status, :status_details, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :required_investigations, :location_opened_old, :not_performed, :referral_fax, :referral_phone, :referral_other_details, :referral_details, :referral_form_old, :referral_form_mask, :lagtime_mask, :waittime_mask, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :patient_can_book_old, :patient_can_book_mask, :red_flags, :urgent_fax, :urgent_phone, :urgent_other_details, :urgent_details, :responds_via, :patient_instructions, :cancellation_policy, :interpreter_available, :specialization_ids, :deprecated_schedule_attributes, :language_ids, :attendances_attributes, :focuses_attributes, :healthcare_provider_ids, :user_controls_clinic_locations_attributes, :admin_notes, :referral_forms_attributes, :clinic_locations_attributes, :review_object
  has_paper_trail :ignore => :saved_token
  
  #clinics can have multiple specializations
  has_many :clinic_specializations, :dependent => :destroy
  has_many :specializations, :through => :clinic_specializations
  
  #clinics have multiple locations
  MAX_LOCATIONS = 6
  has_many :clinic_locations, :dependent => :destroy
  accepts_nested_attributes_for :clinic_locations
  has_many :locations, :through => :clinic_locations
  has_many :addresses, :through => :locations
  
  #clinics speak many languages
  has_many   :clinic_speaks, :dependent => :destroy, :dependent => :destroy
  has_many   :languages, :through => :clinic_speaks, :order => "name ASC"
  
  #clinics have multiple referral forms
  has_many   :referral_forms, :as => :referrable
  accepts_nested_attributes_for :referral_forms, :allow_destroy => true
  
  #clinics focus on procedures
  has_many   :focuses, :dependent => :destroy
  has_many   :procedure_specializations, :through => :focuses
  has_many   :procedures, :through => :procedure_specializations
  accepts_nested_attributes_for :focuses, :reject_if => lambda { |a| a[:procedure_specialization_id].blank? }, :allow_destroy => true
  
  #clinics have attendance (of specialists and freeform physicians)
  has_many :attendances, :through => :clinic_locations
  has_many :specialists, :through => :attendances
  
  #clinics have many healthcare providers
  has_many   :clinic_healthcare_providers, :dependent => :destroy
  has_many   :healthcare_providers, :through => :clinic_healthcare_providers, :order => "name ASC"
  
  #clinics are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_clinic_locations, :through => :clinic_locations
  has_many :controlling_users, :through => :user_controls_clinic_locations, :source => :user, :class_name => "User"
  accepts_nested_attributes_for :user_controls_clinic_locations, :reject_if => lambda { |uccl| uccl[:user_id].blank? }, :allow_destroy => true
  
  has_one :review_item, :as => :item, :conditions => { "archived" => false }
  has_many :feedback_items, :as => :item, :conditions => { "archived" => false }
  
  default_scope order('clinics.name')
  
  def self.not_in_progress_for_divisions(divisions)
    division_ids = divisions.map{ |division| division.id }
    joins('INNER JOIN "clinic_specializations" ON "clinics"."id" = "clinic_specializations"."clinic_id" INNER JOIN "specialization_options" ON "specialization_options"."specialization_id" = "clinic_specializations"."specialization_id"').where('"specialization_options"."division_id" IN (?) AND "specialization_options"."in_progress" = (?)', division_ids, false)
  end
  
  def self.not_in_progress
    joins('INNER JOIN "clinic_specializations" AS "cs2" ON "clinics"."id" = "cs2"."clinic_id" INNER JOIN "specialization_options" ON "specialization_options"."specialization_id" = "cs2"."specialization_id"').where('"specialization_options"."in_progress" = (?)', false)
  end

  def in_progress_for_divisions(divisions)
    specialization_options = specializations.map{ |s| s.specialization_options.for_divisions(divisions) }.flatten
    (specialization_options.length > 0) && (specialization_options.reject{ |so| so.in_progress }.length == 0)
  end
  
  CATEGORIZATION_HASH = {
    1 => "Responded to survey",
    2 => "Not responded to survey",
    3 => "Purposely not yet surveyed",
  }
  
  def self.in_cities(cities)
    city_ids = cities.map{ |city| city.id }
    direct = joins('INNER JOIN "clinic_locations" as "direct_clinic_location" ON "clinics".id = "direct_clinic_location".clinic_id INNER JOIN "locations" AS "direct_location" ON "direct_clinic_location".id = "direct_location".locatable_id INNER JOIN "addresses" AS "direct_address" ON "direct_location".address_id = "direct_address".id').where('"direct_location".locatable_type = (?) AND "direct_address".city_id in (?) AND "direct_location".hospital_in_id IS NULL', "ClinicLocation", city_ids)
    in_hospital = joins('INNER JOIN "clinic_locations" as "direct_clinic_location" ON "clinics".id = "direct_clinic_location".clinic_id INNER JOIN "locations" AS "direct_location" ON "direct_clinic_location".id = "direct_location".locatable_id INNER JOIN "hospitals" ON "hospitals".id = "direct_location".hospital_in_id INNER JOIN "locations" AS "hospital_in_location" ON "hospitals".id = "hospital_in_location".locatable_id INNER JOIN "addresses" AS "hospital_address" ON "hospital_in_location".address_id = "hospital_address".id').where('"direct_location".locatable_type = (?) AND "hospital_in_location".locatable_type = (?) AND "hospital_address".city_id in (?)', "ClinicLocation", "Hospital", city_ids)
    (direct + in_hospital).uniq
  end

  def self.in_divisions(divisions)
    self.in_cities(divisions.map{ |division| division.cities }.flatten.uniq)
  end

  def self.in_local_referral_area_for_specializaton_and_division(specialization, division)
    self.in_cities(division.local_referral_cities_for_specialization(specialization))
  end
  
  def responded?
    categorization_mask == 1
  end
  
  def not_responded?
    categorization_mask == 2
  end
  
  def purposely_not_yet_surveyed?
    categorization_mask == 3
  end
  
  def show_in_table?
    responded? || not_responded?
  end

  def show_wait_time_in_table?
    responded? && accepting_new_patients?
  end

  def not_available?
    false #to line up with specialists; all are "available" if they exist
  end
  
  def city_old
    l = locations.first
    return nil if l.blank?
    return l.city
  end

  def cities
    return locations.map{ |l| l.city }.reject{ |c| c.blank? }.uniq
  end

  def resolved_address_old
    return location.resolved_address if location
    return nil
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
        options = []
        specializations.each{ |specialization| options << specialization.specialization_options.for_divisions(intersecting_divisions) }
        options.flatten.each do |so|
          return so.owner if so.owner.present?
        end
      end
    end
    
    #We either didn't pass in a division, or the interesection was blank with the clinic's actual divisions.
    #So just return the owner for the clinic's division
    specializations.each do |specialization|
      specialization.specialization_options.for_divisions(divisions).each do |so|
        return so.owner if so.owner.present?
      end
    end
    
    #There is no owner for the any of the specializations this clinic is in...
    return default_owner
  end
  
  def attendances?
    attendances.each do |attendance|
      if attendance.is_specialist && attendance.specialist
        return true
      elsif !attendance.is_specialist && !attendance.freeform_name.blank?
        return true
      end
    end
    return false
  end
  
  STATUS_HASH = { 
    1 => "Accepting new referrals", 
    2 => "Only doing follow up on previous patients",
    3 => "Didn't answer"
  }
  
  def status
    if (status_mask == 3) || status_mask.blank?
      "It is unknown if this clinic is accepting new patients (this clinic didn't respond)"
    else
      Clinic::STATUS_HASH[status_mask]
    end
  end
  
  
  STATUS_CLASS_AVAILABLE    = "icon-ok icon-green"
  STATUS_CLASS_UNAVAILABLE  = "icon-remove icon-red"
  STATUS_CLASS_UNKNOWN      = "icon-question-sign"
  STATUS_CLASS_BLANK        = ""
  
  #match specialist
  STATUS_CLASS_HASH = {
    STATUS_CLASS_AVAILABLE => 1,
    STATUS_CLASS_UNAVAILABLE => 2,
    STATUS_CLASS_UNKNOWN => 4,
    STATUS_CLASS_BLANK => 6,
  }
  
  def status_class
    if not_responded? || (status_mask == 3) || status_mask.blank?
      return STATUS_CLASS_UNKNOWN
    elsif purposely_not_yet_surveyed?
      return STATUS_CLASS_BLANK
    elsif accepting_new_patients?
      return STATUS_CLASS_AVAILABLE
    elsif (status_mask == 2)
      return STATUS_CLASS_UNAVAILABLE
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
    10 => "18-24 months",
    11 => "2-2.5 years",
    12 => "2.5-3 years",
    13 => ">3 years"
  }
  
  def waittime
    waittime_mask.present? ? Clinic::WAITTIME_HASH[waittime_mask] : ""
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
    11 => "18-24 months",
    12 => "2-2.5 years",
    13 => "2.5-3 years",
    14 => ">3 years"
  }
  
  def lagtime
    Clinic::LAGTIME_HASH[lagtime_mask]
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
      return "#{output.punctuate} #{referral_details.punctuate.convert_newlines_to_br}".html_safe
    else
      return output.punctuate
    end
  end
  
  def responds_via
    if (not respond_by_phone) && (not respond_by_fax) && (not respond_by_mail) && (not respond_to_patient)
      return ""
    elsif (not respond_by_phone) && (not respond_by_fax) && (not respond_by_mail) && respond_to_patient
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
        return output.capitalize_first_letter + ", and by directly contacting the patient."
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
      return "#{output.punctuate} #{urgent_details.punctuate.convert_newlines_to_br}".html_safe
    else
      return output.punctuate
    end
  end

  def opened_recently?
    clinic_locations.reject{ |cl| !cl.opened_recently? }.present?
  end

  def wheelchair_accessible?
    clinic_locations.reject{ |cl| !cl.wheelchair_accessible? }.present?
  end

  def days
    clinic_locations.reject{ |cl| !cl.scheduled? }.map{ |cl| cl.schedule.days }.flatten.uniq
  end

  def private?
    clinic_locations.reject{ |cl| !cl.private? }.present?
  end
  
  def new?
    (created_at > 3.week.ago.utc) && opened_recently?
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end
end
