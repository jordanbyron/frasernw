class Specialist < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :responded, :billing_number, :practise_limitations, :interest, :procedure_ids, :direct_phone, :red_flags, :clinic_ids, :responds_via, :contact_name, :contact_email, :contact_phone, :contact_notes, :referral_criteria, :status_mask, :location_opened, :referral_fax, :referral_phone, :referral_other_details, :urgent_fax, :urgent_phone, :urgent_other_details, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :status_details, :required_investigations, :not_performed, :patient_can_book_old, :patient_can_book_mask, :lagtime_mask, :waittime_mask, :referral_form_old, :referral_form_mask, :unavailable_from, :unavailable_to, :hospital_ids, :specializations_including_in_progress_ids, :capacities_attributes, :offices_attributes, :language_ids, :addresses_attributes
  has_paper_trail ignore: :saved_token
  
  # specialists can have multiple specializations
  has_many :specialist_specializations, :dependent => :destroy
  has_many :specializations, :through => :specialist_specializations, :conditions => { "in_progress" => false }
  has_many :specializations_including_in_progress, :through => :specialist_specializations, :source => :specialization, :class_name => "Specialization"

  # specialists have the capacity to perform procedures
  has_many   :capacities, :dependent => :destroy
  has_many   :procedure_specializations, :through => :capacities
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
  
  # specialists are favorited by users of the system
  has_many   :favorites
  has_many   :users, :through => :favorites
  
  #specialist are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_specialists
  has_many :controlling_users, :through => :user_controls_specialists, :source => :specialist, :class_name => "Specialist"

  # has many contacts - dates and times they were contacted
  has_many  :contacts

  # dates and times they looked at and changed their own record
  has_many  :views
  has_many  :edits

  has_many :offices
  accepts_nested_attributes_for :offices
  
  MAX_ADDRESSES = 2
  has_many :specialist_addresses
  has_many :addresses, :through => :specialist_addresses
  accepts_nested_attributes_for :addresses

  validates_presence_of :firstname, :on => :save, :message => "can't be blank"
  validates_presence_of :lastname, :on => :save, :message => "can't be blank"
  #validates_length_of :specialist_specializations, :minimum => 1, :message => "require at least one set"

  default_scope order('lastname, firstname')
  
  STATUS_HASH = { 
    1 => "Accepting new patients", 
    2 => "Only doing follow up on previous patients", 
    3 => "Semi-retired", 
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
    elsif (status_mask == 7 or (not status_mask.presence))
      "It is unknown if this specialist is accepting new patients (they didn't answer)"
    else
      Specialist::STATUS_HASH[status_mask]
    end
  end
  
  def status_class
    if not responded
      return "unknown"
    elsif ((status_mask == 1) or ((status_mask == 6) and (unavailable_to < Date.today)))
      #marked as available, or the "unavailable between" period has passed
      return "available"
    elsif ((status_mask == 2) or (status_mask == 4) or ((status_mask == 5) and (unavailable_from <= Date.today)) or ((status_mask == 6) and (unavailable_from <= Date.today) and (unavailable_to >= Date.today)))
      #only seeing old patients, retired, "retiring as of" date has passed", or in midst of inavailability
      return "unavailable"
    elsif (((status_mask == 5) and (unavailable_from > Date.today)) or ((status_mask == 6) and (unavailable_from > Date.today)))
      return "warning"
    elsif ((status_mask == 3) or (status_mask == 7))
      return "unknown"
    else
      #this shouldn't really happen
      return "unknown"
    end
  end
  
  def retired?
    return ((status_mask == 4) or ((status_mask == 5) and (unavailable_from <= Date.today)))
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
    waittime_mask.presence ? Specialist::WAITTIME_HASH[waittime_mask] : "Unknown"
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
  
  def referral_form
    Specialist::BOOLEAN_HASH[referral_form_mask]
  end
  
  def patient_can_book
    Specialist::BOOLEAN_HASH[patient_can_book_mask]
  end

  def name
    firstname + ' ' + lastname
  end
  
  def billing_number_padded
    "%05d" % billing_number if billing_number else ""
  end
    
  def practice_limitations
    return practise_limitations
  end
  
  def accepts_referrals_via
    if referral_phone and referral_fax and referral_other_details.presence
      return "phone, fax, or " + referral_other_details
    elsif referral_phone and referral_fax
      return "phone or fax"
    elsif referral_phone
      if referral_other_details.presence
        return "phone or " + referral_other_details
      else
        return "phone"
      end
    elsif referral_fax
      if referral_other_details.presence
        return "fax or " + referral_other_details
      else
        return "fax"
      end
    elsif referral_other_details.presence
      return referral_other_details
    else
      return "unspecified"
    end
  end
  
  def responds_via
    if (not respond_by_phone) and (not respond_by_fax) and (not respond_by_mail) and (not respond_to_patient)
      return ""
    elsif (not respond_by_phone) and (not respond_by_fax) and (not respond_by_mail) and respond_to_patient
      return "directly to patient"
    else
      if respond_by_phone and respond_by_fax and respond_by_mail
        output = "phone, fax, or mail to referring office"
      elsif respond_by_phone and respond_by_fax and (not respond_by_mail)
        output = "phone or fax to referring office"
      elsif respond_by_phone and (not respond_by_fax) and respond_by_mail
        output = "phone or mail to referring office"
      elsif respond_by_phone and (not respond_by_fax) and (not respond_by_mail)
        output = "phone to referring office"
      elsif (not respond_by_phone) and respond_by_fax and respond_by_mail
        output = "fax or mail to referring office"
      elsif (not respond_by_phone) and respond_by_fax and (not respond_by_mail)
        output = "fax to referring office"
      else # must be (not respond_by_phone) and (not respond_by_fax) and respond_by_mail
        output = "mail to referring office"
      end
      
      if respond_to_patient
        return output + ", and directly to patient"
      else
        return output
      end
    end
  end
  
  def urgent_referrals_via
    if urgent_phone and urgent_fax and urgent_other_details.presence
      return "phone, fax, or " + urgent_other_details
    elsif urgent_phone and urgent_fax
      return "phone or fax"
    elsif urgent_phone
      output = "phone"
      if urgent_other_details.presence
        return output + " or " + urgent_other_details
      end
    elsif urgent_fax
      output = "fax"
      if urgent_other_details.presence
        return output + " or " + urgent_other_details
      end
    elsif urgent_other_details.presence
      return referral_other_details
    else
      return ""
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
