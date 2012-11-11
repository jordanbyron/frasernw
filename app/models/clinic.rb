class Clinic < ActiveRecord::Base
  include ApplicationHelper
  
  attr_accessible :name, :phone, :phone_extension, :fax, :contact_details, :categorization_mask, :sector_mask, :url, :email, :wheelchair_accessible_mask, :status, :status_details, :interest, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :required_investigations, :location_opened, :not_performed, :referral_fax, :referral_phone, :referral_other_details, :referral_details, :referral_form_old, :referral_form_mask, :lagtime_mask, :waittime_mask, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :patient_can_book_old, :patient_can_book_mask, :red_flags, :urgent_fax, :urgent_phone, :urgent_other_details, :urgent_details, :responds_via, :patient_instructions, :cancellation_policy, :interpreter_available, :specializations_including_in_progress_ids, :location_attributes, :schedule_attributes, :language_ids, :attendances_attributes, :focuses_attributes, :healthcare_provider_ids, :user_controls_clinics_attributes, :admin_notes, :referral_forms_attributes
  has_paper_trail :ignore => :saved_token
  
  #clinics can have multiple specializations
  has_many :clinic_specializations, :dependent => :destroy
  has_many :specializations, :through => :clinic_specializations, :conditions => { "in_progress" => false }
  has_many :specializations_including_in_progress, :through => :clinic_specializations, :source => :specialization, :class_name => "Specialization"
  
  #clinics have an address
  has_one :location, :as => :locatable, :dependent => :destroy
  has_one :address, :through => :location
  accepts_nested_attributes_for :location
  
  #clinics can have locations that are within them
  has_many :locations_in, :foreign_key => :clinic_in_id, :class_name => "Location"
  has_many :direct_offices_in, :through => :locations_in, :source => :locatable, :source_type => "Office"
  has_many :specialists_in, :through => :direct_offices_in, :source => :specialists, :class_name => "Specialist", :uniq => true
  has_many :specializations_in, :through => :specialists_in, :source => :specializations, :class_name => "Specialization", :uniq => true, :select => "DISTINCT specializations.*, specialists.firstname, specialists.lastname"
  has_many :procedures_in, :through => :specialists_in, :source => :procedures, :class_name => "Procedure", :uniq => true, :select => "DISTINCT procedures.*, specialists.firstname, specialists.lastname"
  
  #clinics have a schedule
  has_one :schedule, :as => :schedulable, :dependent => :destroy
  accepts_nested_attributes_for :schedule
  
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
  has_many :attendances, :dependent => :destroy
  has_many :specialists, :through => :attendances
  accepts_nested_attributes_for :attendances, :allow_destroy => true
  
  #clinics have many healthcare providers
  has_many   :clinic_healthcare_providers, :dependent => :destroy
  has_many   :healthcare_providers, :through => :clinic_healthcare_providers, :order => "name ASC"
  
  #clinics are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_clinics, :dependent => :destroy
  has_many :controlling_users, :through => :user_controls_clinics, :source => :user, :class_name => "User"
  accepts_nested_attributes_for :user_controls_clinics, :reject_if => lambda { |ucc| ucc[:user_id].blank? }, :allow_destroy => true
  
  has_one :review_item, :as => :item, :conditions => { "archived" => false }
  has_many :feedback_items, :as => :item, :conditions => { "archived" => false }
  
  default_scope order('clinics.name')
  
  CATEGORIZATION_HASH = {
    1 => "Responded to survey",
    2 => "Not responded to survey",
    3 => "Purposely not yet surveyed",
  }
  
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
  
  def disabled_in_table?
    not_responded?
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
  
  def city
    l = location
    return nil if l.blank?
    a = l.resolved_address
    return nil if a.blank? || a.city.blank?
    return a.city
  end
  
  def city_entity
    l = location
    return nil if l.blank?
    a = l.resolved_address
    return a.present? ? a.city : nil
  end
  
  def resolved_address
    return location.resolved_address if location
    return nil
  end
  
  def divisions
    return city.present? ? city.divisions : []
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
    
    #We either didn't pass in a division, or the interesection was blank with the clinic's actual divisions.
    #So just return the owner for the clinic's division
    divisions.each do |division|
      specializations.specialization_owners.for_division(division).each do |specialization_owner|
        if specialization_owner.owner.present?
          return specialization_owner.owner
        end
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
    1 => "Accepting new patients", 
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
    if not_responded? || status_mask.blank?
      return STATUS_CLASS_UNKNOWN
    elsif purposely_not_yet_surveyed?
      return STATUS_CLASS_BLANK
    elsif (status_mask == 1)
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
    11 => ">18 months"
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
    Clinic::SECTOR_HASH[sector_mask]
  end
  
  def sector?
    sector_mask != 4
  end
  
  def scheduled?
    schedule.scheduled?
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

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end
end
