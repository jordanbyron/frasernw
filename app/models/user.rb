class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options({:minimum => 8})
    c.merge_validates_uniqueness_of_email_field_options({:message => "has already been used to set up another account. Pleast use a different email address to sign up, or sign into your existing account."})
    c.logged_in_timeout = 1.week
  end

  validates_format_of :password, :with => /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,}$/, :if => :require_password?, :message => "must include one number, one letter and be at least 8 characters long"
  
  has_many :user_divisions, :source => :division_users, :class_name => "DivisionUser", :dependent => :destroy
  has_many :divisions, :through => :user_divisions
  #has_many :cities, :through => :divisions

  has_many :favorites
  has_many :favorite_specialists, :through => :favorites, :source => :favoritable, :source_type => "Specialist", :class_name => "Specialist"
  has_many :favorite_clinics, :through => :favorites, :source => :favoritable, :source_type => "Clinic", :class_name => "Clinic"
  has_many :favorite_content_items, :through => :favorites, :source => :favoritable, :source_type => "ScItem", :class_name => "ScItem"
  
  has_many :user_controls_specialist_offices, :dependent => :destroy
  has_many :controlled_specialist_offices, :through => :user_controls_specialist_offices, :source => :specialist_office, :class_name => "SpecialistOffice"
  has_many :controlled_specialists, :through => :controlled_specialist_offices, :source => :specialist, :class_name => "Specialist"
  accepts_nested_attributes_for :user_controls_specialist_offices, :reject_if => lambda { |ucso| ucso[:specialist_office_id].blank? }, :allow_destroy => true
  
  has_many :user_controls_clinic_locations, :dependent => :destroy
  has_many :controlled_clinic_locations, :through => :user_controls_clinic_locations, :source => :clinic_location, :class_name => "ClinicLocation"
  has_many :controlled_clinics, :through => :controlled_clinic_locations, :source => :clinic, :class_name => "Clinic"
  accepts_nested_attributes_for :user_controls_clinic_locations, :reject_if => lambda { |uccl| uccl[:clinic_location_id].blank? }, :allow_destroy => true

  has_many :specialization_options, :dependent => :destroy, :foreign_key => "owner_id"
  has_many :specializations_owned, :through => :specialization_options, :class_name => "Specialization", :source => :specialization
  
  has_many :user_cities, :dependent => :destroy
  has_many :user_city_specializations, :through => :user_cities

  has_many :subscriptions, :dependent => :destroy

  # times that the user (as admin) has contacted specialists
  has_many :contacts

  validates_presence_of :name
  validates :agree_to_toc, presence: true

  default_scope order('users.name')

LIMITED_ROLE_HASH = {
    "user" => "User",
    "admin" => "Administrator"
  }

  ROLE_HASH = {
    "user" => "User",
    "admin" => "Administrator",
    "super" => "Super Administrator"
  }

  def self.user
    where("users.role = 'user'")
  end

  def self.active_user
    where("users.role = 'user' AND users.active = (?) AND COALESCE(users.email,'') != ''", true)
  end

  def self.admin_only
    where("users.role = 'admin'")
  end

  def self.active_admin_only
    where("users.role = 'admin' AND users.active = (?) AND COALESCE(users.email,'') != ''", true)
  end

  def self.admin
    where("users.role = 'admin' OR users.role = 'super'")
  end

  def self.super_admin
    where("users.role = 'super'")
  end

  def self.active_super_admin
    where("users.role = 'super' AND users.active = (?) AND COALESCE(users.email,'') != ''", true)
  end

  def self.active_pending
    where("COALESCE(users.email,'') = '' AND users.active = (?)", true)
  end

  def self.active
    where("users.active = (?)", true)
  end

  def self.inactive
    where("users.active = (?)", false)
  end

  def self.with_subscriptions #return only admins/super-admins with subscriptions created
    admin.reject{|u| u.subscriptions.empty?}
  end

  def self.in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(:user_divisions).where('"division_users"."division_id" IN (?)', division_ids)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!  
    PasswordResetMailer.password_reset_instructions(self).deliver
  end  
  
  def active?
    active
  end
  
  def user?
    (self.role == 'user')
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

  def subscriptions_by_date_interval(date_interval)
    subscriptions.select{|s| s.interval == date_interval}
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

  # returns true when a user has an overlapping referral_city from a given array of cities (e.g. specialist.cities / clinic.cities)
  def shares_local_referral_city?(cities)
    !(cities & self.divisions.map{|d| d.referral_cities}.flatten.uniq).blank?
  end

  # returns true if a user does not have an overlapping referral_city from a given array of cities (e.g. specialist.cities / clinic.cities)
  def does_not_share_local_referral_city?(cities)
    (cities & self.divisions.map{|d| d.referral_cities}.flatten.uniq).blank?
  end

  def owns(specializations)
    does_own = false
    specializations.each do |specialization|
      does_own |= SpecializationOption.find_by_specialization_id_and_owner_id(specialization.id, self.id).present?
    end
    does_own
  end

  def local_referral_cities_for_specialization(specialization)
    return user_city_specializations.reject{ |ucs| ucs.specialization_id != specialization.id }.map{ |ucs| ucs.user_city.city }
  end

  def self.import(file, divisions, type_mask, role)
    users = []
    CSV.foreach(file.path) do |row|
      user = User.new(:name => row[0], :divisions => divisions, :type_mask => type_mask, :role => role)
      if user.save :validate => false #so we can avoid setting up with emails or passwords
        users << user
      else
        puts "ERROR SETTING UP #{row[0]}"
      end
    end
    users
  end
end
