class Clinic < ActiveRecord::Base
  attr_accessible :name, :responded, :status, :interest, :waittime, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :required_investigations, :location_opened, :not_performed, :referral_fax, :referral_phone, :referral_other_details, :referral_form_old, :referral_form_mask, :lagtime_mask, :waittime_mask, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :patient_can_book_old, :patient_can_book_mask, :red_flags, :urgent_fax, :urgent_phone, :urgent_other_details, :responds_via, :clinic_specializations_attributes, :addresses_attributes, :language_ids, :attendances_attributes, :focuses_attributes, :healthcare_provider_ids
  has_paper_trail meta: { to_review: false }
  
  # clinics can have multiple specializations
  has_many :clinic_specializations, :dependent => :destroy
  has_many :specializations, :through => :clinic_specializations
  accepts_nested_attributes_for :clinic_specializations, :allow_destroy => true
  
  # clinics can have more than one address
  MAX_ADDRESSES = 2
  has_many :clinic_addresses
  has_many :addresses, :through => :clinic_addresses
  accepts_nested_attributes_for :addresses
  
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
  
  default_scope order('name')
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_length_of :clinic_specializations, :minimum => 1, :message => "require at least one set"
  
  STATUS_HASH = { 
    1 => "Accepting new patients", 
    2 => "Only doing follow up on previous patients",
    3 => "Didn't answer"
  }
  
  def status
    Clinic::STATUS_HASH[status_mask]
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
    Clinic::WAITTIME_HASH[waittime_mask]
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
  
  def referral_form
    Specialist::BOOLEAN_HASH[referral_form_mask]
  end
  
  def patient_can_book
    Specialist::BOOLEAN_HASH[patient_can_book_mask]
  end

end
