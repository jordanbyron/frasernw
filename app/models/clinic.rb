class Clinic < ActiveRecord::Base
  attr_accessible :name, :address1, :address2, :postalcode, :city, :province, :phone1, :fax, :status, :interest, :waittime, :specialization_id, :referral_criteria, :referral_process, :contact_name, :contact_email, :contact_phone, :contact_notes, :status_mask, :limitations, :location_opened, :procedure_ids, :responds_via, :addresses_attributes
  has_paper_trail meta: { to_review: false }
  
  has_many :attendances
  has_many :specialists, :through => :attendances
  
  belongs_to :specialization
  
  validates_presence_of :specialization_id, :on => :create, :message => "can't be blank"
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  # clinics focus on procedures
  has_many   :focuses
  has_many   :procedures, :through => :focuses
  
  MAX_ADDRESSES = 2
  has_many :clinic_addresses
  has_many :addresses, :through => :clinic_addresses
  accepts_nested_attributes_for :addresses
  
  STATUS_HASH = { 1 => "Accepting new patients", 2 => "Only doing follow up on previous patients" }
  
  def status
    Clinic::STATUS_HASH[status_mask]
  end
  
  def address
    address = ''
    address += self.address1 || ''
    address += self.address2 || ''
    address
  end
  
  def waittime_or_blank
    self.waittime.blank? ? "n/a" : self.waittime
  end
  
  def waittime?
    self.waittime.blank? ? 'muted' : ''
  end

end
