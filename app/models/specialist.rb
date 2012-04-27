class Specialist < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :goes_by_name, :sex_mask, :categorization_mask, :billing_number, :practise_limitations, :interest, :procedure_ids, :direct_phone_old, :direct_phone_extension_old, :red_flags, :clinic_ids, :responds_via, :contact_name, :contact_email, :contact_phone, :contact_notes, :referral_criteria, :status_mask, :location_opened, :referral_fax, :referral_phone, :referral_clinic_id, :referral_other_details, :referral_details, :urgent_fax, :urgent_phone, :urgent_other_details, :urgent_details, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :status_details, :required_investigations, :not_performed, :patient_can_book_old, :patient_can_book_mask, :lagtime_mask, :waittime_mask, :referral_form_old, :referral_form_mask, :unavailable_from, :unavailable_to, :patient_instructions, :cancellation_policy, :hospital_ids, :specializations_including_in_progress_ids, :capacities_attributes, :language_ids, :user_controls_specialists_attributes, :specialist_offices_attributes, :admin_notes, :referral_forms_attributes
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
  has_many   :users, :through => :favorites
  
  #specialist are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_specialists, :dependent => :destroy
  has_many :controlling_users, :through => :user_controls_specialists, :source => :user, :class_name => "User"
  accepts_nested_attributes_for :user_controls_specialists, :reject_if => lambda { |ucs| ucs[:user_id].blank? }, :allow_destroy => true

  # has many contacts - dates and times they were contacted
  has_many  :contacts

  # dates and times they looked at and changed their own record
  has_many  :views
  has_many  :edits
  
  MAX_OFFICES = 2
  has_many :specialist_offices, :dependent => :destroy
  has_many :offices, :through => :specialist_offices
  has_many :locations, :through => :offices
  accepts_nested_attributes_for :specialist_offices
  
  def city
    return "" if moved_away?
    o = offices.first
    return "" if o.blank?
    return o.city
  end
  
  def city_id
    return nil if moved_away?
    o = offices.first
    return o.present? ? o.city_id : nil
  end
  
  has_one :review_item, :as => :item
  
  #clinic that referrals are done through
  belongs_to :referral_clinic, :class_name => "Clinic"

  default_scope order('lastname, firstname')
  
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
  
  STATUS_HASH = { 
    1 => "Accepting new patients", 
    2 => "Only doing follow up on previous patients", 
    4 => "Retired",
    5 => "Retiring as of",
    6 => "Unavailable between",
    7 => "Didn't answer"
  }
  
  def status
    if status_mask == 5
      if unavailable_from <= Date.today
        #retiring as of date has passed, retired
        Specialist::STATUS_HASH[4]
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
  
  def status_class
    if not_responded? || hospital_or_clinic_only? || purposely_not_yet_surveyed?
      return "unknown"
    elsif ((status_mask == 1) || ((status_mask == 6) && (unavailable_to < Date.today)))
      #marked as available, or the "unavailable between" period has passed
      return "available"
    elsif ((status_mask == 2) || (status_mask == 4) || ((status_mask == 5) && (unavailable_from <= Date.today)) || ((status_mask == 6) && (unavailable_from <= Date.today) && (unavailable_to >= Date.today)) || moved_away?)
      #only seeing old patients, retired, "retiring as of" date has passed", or in midst of inavailability, or moved away
      return "unavailable"
    elsif (((status_mask == 5) && (unavailable_from > Date.today)) || ((status_mask == 6) && (unavailable_from > Date.today)))
      return "warning"
    elsif ((status_mask == 3) || (status_mask == 7))
      return "unknown"
    else
      #this shouldn't really happen
      return "unknown"
    end
  end
  
  def retired?
    return ((status_mask == 4) || ((status_mask == 5) && (unavailable_from <= Date.today)))
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
      output = "phone, fax, or #{referral_other_details}."
    elsif referral_phone && referral_fax
      output = "phone or fax."
    elsif referral_phone
      if referral_other_details.present?
        output = "phone or #{referral_other_details}."
      else
        output = "phone."
      end
    elsif referral_fax
      if referral_other_details.present?
        output = "fax or #{referral_other_details}."
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
      return "#{output} #{referral_details.punctuate}"
    else
      return output
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
        return output + ", and by directly contacting the patient."
      else
        return output.end_with_period
      end
    end
  end
  
  def urgent_referrals_via
    if urgent_phone && urgent_fax
      if urgent_other_details.present?
        output = "phone, fax, or #{urgent_other_details}."
      else
        output = "phone or fax."
      end
    elsif urgent_phone
      if urgent_other_details.present?
        output = "phone or #{urgent_other_details}."
      else
        output = "phone."
      end
    elsif urgent_fax
      if urgent_other_details.present?
        output = "fax or #{urgent_other_details}."
      else
        output = "fax."
      end
    elsif urgent_other_details.present?
      output = referral_other_details.punctuate
    else
      output = ""
    end
    
    if urgent_details.present?
      return "#{output} #{urgent_details.punctuate}"
    else
      return output
    end
  end
  
  def child_procedures(procedure)
    result = []
    procedure.procedure_specializations.each do |ps|
      next if not ps.has_children?
      result += (ProcedureSpecialization.descendants_of(ps) & self.procedure_specializations)
    end
    result.uniq!
    return result.compact.collect{ |ps| ps.procedure } if result else []
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      self.saved_token = SecureRandom.hex(16)
      self.save
      return self.saved_token
    end
  end
  
end
