class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options({:minimum => 6})
    c.merge_validates_uniqueness_of_email_field_options({:message => "has already been used to set up another account."})
    c.logged_in_timeout = 1.week
  end
  
  has_many :user_divisions, :source => :division_users, :class_name => "DivisionUser", :dependent => :destroy
  has_many :divisions, :through => :user_divisions
  has_many :cities, :through => :divisions

  has_many :favorites
  has_many :favorite_specialists, :through => :favorites, :source => :favoritable, :source_type => "Specialist", :class_name => "Specialist"
  has_many :favorite_clinics, :through => :favorites, :source => :favoritable, :source_type => "Clinic", :class_name => "Clinic"
  has_many :favorite_content_items, :through => :favorites, :source => :favoritable, :source_type => "ScItem", :class_name => "ScItem"
  
  has_many :user_controls_specialist_offices, :dependent => :destroy
  has_many :controlled_specialist_offices, :through => :user_controls_specialist_offices, :source => :specialist_office, :class_name => "SpecialistOffice"
  has_many :controlled_specialists, :through => :controlled_specialist_offices, :source => :specialist, :class_name => "Specialist"
  accepts_nested_attributes_for :user_controls_specialist_offices, :reject_if => lambda { |ucso| ucso[:specialist_office_id].blank? }, :allow_destroy => true
  
  has_many :user_controls_clinics, :dependent => :destroy
  has_many :controlled_clinics, :through => :user_controls_clinics, :source => :clinic, :class_name => "Clinic"
  accepts_nested_attributes_for :user_controls_clinics, :reject_if => lambda { |ucc| ucc[:clinic_id].blank? }, :allow_destroy => true

  has_many :specialization_owners, :dependent => :destroy, :foreign_key => "owner_id"
  has_many :specializations, :through => :specialization_owners

  # times that the user (as admin) has contacted specialists
  has_many :contacts

  validates_presence_of :name
  validates :agree_to_toc, presence: true
  
  default_scope order('users.name')

  LIMITED_ROLE_HASH = {
    "user" => "User",
  }

  ROLE_HASH = {
    "user" => "User",
    "admin" => "Administrator",
    "super" => "Super Administrator",
  }

  def deliver_password_reset_instructions!
    reset_perishable_token!  
    PasswordResetMailer.password_reset_instructions(self).deliver
  end  
  
  def active?
    active
  end
  
  def admin_only?
    (self.role == 'admin')
  end
  
  def admin?
    admin_only? || super_admin?
  end
  
  def super_admin?
    self.role == 'super'
  end
  
  def pending?
    self.email.blank?
  end

  def role_full
    User::ROLE_HASH[self.role]
  end

  TYPE_HASH = {
    1 => "GP Office",
    2 => "Specialist Office",
    3 => "Clinic",
    5 => "Hospitalist",
    6 => "Locum",
    7 => "Resident",
    8 => "Nurse Practitioner",
    9 => "Unit Clerk",
    4 => "Other"
  }

  def type
    User::TYPE_HASH[type_mask]
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      saved_token = SecureRandom.hex(4) #length will be double this, giving us 16^8 or 4,294,967,296 different tokens
      while User.find_by_saved_token(saved_token).present?
        #ensure no saved_token collisions
        saved_token = SecureRandom.hex(4)
      end
      update_column(:saved_token, saved_token)
      return self.saved_token
    end
  end

  def owns(specializations)
    does_own = false
    specializations.each do |specialization|
      does_own |= SpecializationOwner.find_by_specialization_id_and_owner_id(specialization.id, self.id).present?
    end
    does_own
  end
end
