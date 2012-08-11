class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options({:minimum => 6})
    c.merge_validates_uniqueness_of_email_field_options({:message => "has already been used to set up another account."})
    c.logged_in_timeout = 1.week
  end

  has_many :favorites
  has_many :favorite_specialists, :through => :favorites, :source => :favoritable, :source_type => "Specialist", :class_name => "Specialist"
  has_many :favorite_clinics, :through => :favorites, :source => :favoritable, :source_type => "Clinic", :class_name => "Clinic"
  has_many :favorite_specializations, :through => :favorites, :source => :favoritable, :source_type => "Specialization", :class_name => "Specialization"
  has_many :favorite_procedures, :through => :favorites, :source => :favoritable, :source_type => "Procedure", :class_name => "Procedure"
  
  has_many :user_controls_specialists, :dependent => :destroy
  has_many :controlled_specialists, :through => :user_controls_specialists, :source => :specialist, :class_name => "Specialist"
  accepts_nested_attributes_for :user_controls_specialists, :reject_if => lambda { |ucs| ucs[:specialist_id].blank? }, :allow_destroy => true
  
  has_many :user_controls_clinics, :dependent => :destroy
  has_many :controlled_clinics, :through => :user_controls_clinics, :source => :clinic, :class_name => "Clinic"
  accepts_nested_attributes_for :user_controls_clinics, :reject_if => lambda { |ucc| ucc[:clinic_id].blank? }, :allow_destroy => true

  has_many :specialization_owners, :dependent => :destroy, :foreign_key => "owner_id"
  has_many :specializations, :through => :specialization_owners

  # times that the user (as admin) has contacted specialistscreate
  has_many :contacts

  # has_many :clinics,     :through => :favorites
  validates_presence_of :name
  
  default_scope order('users.name')

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    PasswordResetMailer.password_reset_instructions(self).deliver
  end  
  
  def admin?
    self.role == 'admin'
  end
  
  TYPE_HASH = {
    1 => "GP Office",
    2 => "Specialist Office",
    3 => "Clinic Office",
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
