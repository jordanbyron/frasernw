class Clinic < ActiveRecord::Base
  attr_accessible :name, :address1, :address2, :postalcode, :city, :province, :phone1, :fax, :status, :interest, :waittime, :specialization_id, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :required_investigations, :location_opened, :not_performed, :referral_fax, :referral_phone, :referral_other_details, :referral_form, :lagtime_old, :lag_uom_old, :waittime_old, :wait_uom_old, :respond_by_fax, :respond_by_phone, :respond_by_mail, :respond_to_patient, :patient_can_book, :red_flags, :urgent_fax, :urgent_phone, :urgent_other_details, :responds_via, :addresses_attributes, :language_ids, :attendances_attributes, :focuses_attributes, :healthcare_provider_ids
  has_paper_trail meta: { to_review: false }
  
  belongs_to :specialization
  
  validates_presence_of :specialization_id, :on => :create, :message => "can't be blank"
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  # clinics can have more than one address
  MAX_ADDRESSES = 2
  has_many :clinic_addresses
  has_many :addresses, :through => :clinic_addresses
  accepts_nested_attributes_for :addresses
  
  # clinics speak many languages
  has_many   :clinic_speaks
  has_many   :languages, :through => :clinic_speaks, :order => "name ASC"
  
  # clinics focus on procedures
  has_many   :focuses
  has_many   :procedures, :through => :focuses, :order => "name ASC"
  accepts_nested_attributes_for :focuses, :reject_if => lambda { |a| a[:procedure_id].blank? }, :allow_destroy => true
  
  # clinics have attendance (of specialists and freeform physicians)
  has_many :attendances
  has_many :specialists, :through => :attendances
  accepts_nested_attributes_for :attendances, :allow_destroy => true
  
  # clinics have many healthcare providers
  has_many   :clinic_healthcare_providers
  has_many   :healthcare_providers, :through => :clinic_healthcare_providers, :order => "name ASC"
  
  STATUS_HASH = { 1 => "Accepting new patients", 2 => "Only doing follow up on previous patients" }
  
  def status
    Clinic::STATUS_HASH[status_mask]
  end
  
  def waittime?
    self.waittime_old.blank? ? 'muted' : ''
  end

end
