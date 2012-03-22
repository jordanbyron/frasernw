class Clinic < ActiveRecord::Base
  attr_accessible :name, :phone, :fax, :categorization_mask, :sector_mask, :wheelchair_accessible_mask, :status, :interest, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :required_investigations, :location_opened, :not_performed, :referral_fax, :referral_phone, :referral_other_details, :referral_details, :referral_form_old, :referral_form_mask, :lagtime_mask, :waittime_mask, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :patient_can_book_old, :patient_can_book_mask, :red_flags, :urgent_fax, :urgent_phone, :urgent_other_details, :urgent_details, :responds_via, :patient_instructions, :cancellation_policy, :specializations_including_in_progress_ids, :location_attributes, :schedule_attributes, :language_ids, :attendances_attributes, :focuses_attributes, :healthcare_provider_ids, :user_controls_clinics_attributes, :admin_notes
  has_paper_trail
  
  # clinics can have multiple specializations
  has_many :clinic_specializations, :dependent => :destroy
  has_many :specializations, :through => :clinic_specializations, :conditions => { "in_progress" => false }
  has_many :specializations_including_in_progress, :through => :clinic_specializations, :source => :specialization, :class_name => "Specialization"
  
  # clinics have an address
  has_one :location, :as => :locatable, :dependent => :destroy
  has_one :address, :through => :location
  accepts_nested_attributes_for :location
  
  #clinics have a schedule
  has_one :schedule, :as => :schedulable, :dependent => :destroy
  accepts_nested_attributes_for :schedule
  
  # clinics speak many languages
  has_many   :clinic_speaks, :dependent => :destroy
  has_many   :languages, :through => :clinic_speaks, :order => "name ASC"
  
  # clinics focus on procedures
  has_many   :focuses, :dependent => :destroy
  has_many   :procedure_specializations, :through => :focuses
  accepts_nested_attributes_for :focuses, :reject_if => lambda { |a| a[:procedure_specialization_id].blank? }, :allow_destroy => true
  
  # clinics have attendance (of specialists and freeform physicians)
  has_many :attendances, :dependent => :destroy
  has_many :specialists, :through => :attendances
  accepts_nested_attributes_for :attendances, :allow_destroy => true
  
  # clinics have many healthcare providers
  has_many   :clinic_healthcare_providers, :dependent => :destroy
  has_many   :healthcare_providers, :through => :clinic_healthcare_providers, :order => "name ASC"
  
  #clinics are controlled (e.g. can be edited) by users of the system
  has_many :user_controls_clinics, :dependent => :destroy
  has_many :controlling_users, :through => :user_controls_clinics, :source => :user, :class_name => "User"
  accepts_nested_attributes_for :user_controls_clinics, :reject_if => lambda { |ucc| ucc[:user_id].blank? }, :allow_destroy => true
  
  default_scope order('name')
  
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
  
  def phone_and_fax
    if phone.present? && fax.present?
      return "#{phone}, Fax: #{fax}"
    elsif phone.present?
      return "#{phone}"
    elsif fax.present?
      return "Fax: #{fax}"
    else
      return ""
    end
  end
  
  def city
    l = location
    return "" if l.blank?
    a = l.resolved_address
    return "" if a.blank?
    c = a.city
    c.present? ? c.name : ""
  end
  
  def resolved_address
    return location.resolved_address if location
    return nil
  end
  
  def attendances?
    attendances.each do |attendance|
      if (attendance.is_specialist and attendance.specialist)
        return true
      elsif (!attendance.is_specialist and !attendance.freeform_name.blank?)
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
    if ((status_mask == 3) or (not status_mask.presence))
      "It is unknown if this clinic is accepting new patients (this clinic didn't respond)"
    else
      Clinic::STATUS_HASH[status_mask]
    end
  end
  
  def status_class
    if not_responded? || purposely_not_yet_surveyed?
      return "unknown"
    elsif (status_mask == 1)
      return "available"
    elsif (status_mask == 2)
      return "unavailable"
    else
      #this shouldn't really happen
      return "unknown"
    end
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
    waittime_mask.presence ? Clinic::WAITTIME_HASH[waittime_mask] : ""
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
  
  def wheelchair_accessible?
    wheelchair_accessible_mask == 1
  end
  
  SECTOR_HASH = { 
    1 => "Public", 
    2 => "Private", 
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
    if referral_phone and referral_fax and referral_other_details.presence
      output = "phone, fax, or " + referral_other_details
    elsif referral_phone and referral_fax
      output = "phone or fax"
    elsif referral_phone
      if referral_other_details.presence
        output = "phone or " + referral_other_details
      else
        output = "phone"
      end
    elsif referral_fax
      if referral_other_details.presence
        output = "fax or " + referral_other_details
      else
        output = "fax"
      end
    elsif referral_other_details.presence
      output = referral_other_details
    else
      output = ""
    end
    
    if referral_details.presence
      return "#{output}. #{referral_details.slice(0,1).capitalize + referral_details.slice(1..-1)}"
    else
      return output
    end
  end
  
  def responds_via
    if (not respond_by_phone) and (not respond_by_fax) and (not respond_by_mail) and (not respond_to_patient)
      return ""
    elsif (not respond_by_phone) and (not respond_by_fax) and (not respond_by_mail) and respond_to_patient
      return "directly contacting the patient"
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
        return output + ", and by directly contacting the patient"
      else
        return output
      end
    end
  end
  
  def urgent_referrals_via
    if urgent_phone and urgent_fax
      if urgent_other_details.presence
        output = "phone, fax, or " + urgent_other_details
      else
        output = "phone or fax"
      end
    elsif urgent_phone
      if urgent_other_details.presence
        output = "phone or " + urgent_other_details
      else
        output = "phone"
      end
    elsif urgent_fax
      if urgent_other_details.presence
        output = "fax or " + urgent_other_details
      else
        output = "fax"
      end
    elsif urgent_other_details.presence
      output = referral_other_details
    else
      output = ""
    end
    
    if urgent_details.presence
      return "#{output}. #{urgent_details.slice(0,1).capitalize + urgent_details.slice(1..-1)}"
    else
      return output
    end
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
