class Specialist < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :address1, :address2, :postalcode, :city, :province, :phone1, :fax, :practise_limitations, :interest, :waittime_old, :specialization_id, :procedure_ids, :direct_phone, :red_flags, :clinic_ids, :responds_via, :contact_name, :contact_email, :contact_phone, :contact_notes, :referral_criteria, :status_mask, :location_opened, :referral_fax, :referral_phone, :referral_other_details, :urgent_fax, :urgent_phone, :urgent_other_details, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :status_details, :required_investigations, :not_performed, :lagtime_old, :patient_can_book, :lag_uom_old, :wait_uom_old, :lagtime_mask, :waittime_mask, :referral_form, :hospital_ids, :capacities_attributes, :offices_attributes, :language_ids, :addresses_attributes
  has_paper_trail ignore: :saved_token
  
  belongs_to :specialization

  # specialists have the capacity to perform procedures
  has_many   :capacities
  has_many   :procedures, :through => :capacities
  accepts_nested_attributes_for :capacities, :reject_if => lambda { |a| a[:procedure_id].blank? }, :allow_destroy => true
  
  # specialists attend clinics
  has_many   :attendances
  has_many   :clinics, :through => :attendances
  
  # specialists have "priviliges" at hospitals
  has_many   :privileges
  has_many   :hospitals, :through => :privileges
  
  # specialists "speak" many languages
  has_many   :specialist_speaks
  has_many   :languages, :through => :specialist_speaks
  
  # specialists are favorited by users of the system
  has_many   :favorites
  has_many   :users, :through => :favorites

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
  validates_presence_of :specialization_id, :on => :save, :message => "can't be blank"

  after_initialize :default_values

  default_scope order('lastname, firstname')
  
  STATUS_HASH = { 1 => "Accepting new patients", 2 => "Only doing follow up on previous patients", 3 => "Semi-retired", 4 => "Retired"}
  
  def status
    Specialist::STATUS_HASH[status_mask]
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
    Specialist::WAITTIME_HASH[waittime_mask]
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

  def name
    firstname + ' ' + lastname
  end

  def waittime?
    self.waittime_old.blank? ? 'muted' : ''
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

  private

    def default_values
      self.lag_uom_old ||= "weeks"
      self.wait_uom_old ||= "weeks"
    end

end
