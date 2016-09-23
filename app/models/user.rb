class User < ActiveRecord::Base
  include Historical
  include Noteable
  include HasRole
  include DivisionAdministered

  PAPER_TRAIL_IGNORED_ATTRIBUTES = [
    :persistence_token,
    :crypted_password,
    :password_salt,
    :perishable_token,
    :saved_token,
    :type_mask,
    :last_request_at,
    :failed_login_count,
    :activated_at
  ]
  include PaperTrailable

  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options( { minimum: 8 } )
    c.merge_validates_uniqueness_of_email_field_options( { message:
      "has already been used to set up another account. Pleast use a "\
        "different email address to sign up, or sign into your existing "\
        "account."
    } )
    c.logged_in_timeout = 1.week
    c.crypto_provider = Authlogic::CryptoProviders::Sha512
  end

  validates_format_of :password,
    with: /(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,}/,
    if: :require_password?,
    message: "must include one number, one letter and be at least 8 "\
      "characters long"

  validates :email, confirmation: true

  validates :name, presence: true

  has_many :user_divisions,
    source: :division_users,
    class_name: "DivisionUser",
    dependent: :destroy

  has_many :divisions, through: :user_divisions

  has_many :favorites
  has_many :issue_assignments, dependent: :destroy, foreign_key: :assignee_id
  has_many :assigned_issues,
    through: :issue_assignments,
    class_name: "Issue"
  has_many :issue_subscriptions, dependent: :destroy

  has_many :favorite_specialists,
    through: :favorites,
    source: :favoritable,
    source_type: "Specialist",
    class_name: "Specialist"

  has_many :favorite_clinics,
    through: :favorites,
    source: :favoritable,
    source_type: "Clinic",
    class_name: "Clinic"

  has_many :favorite_content_items,
    through: :favorites,
    source: :favoritable,
    source_type: "ScItem",
    class_name: "ScItem"

  has_many :user_controls_specialists, dependent: :destroy
  accepts_nested_attributes_for :user_controls_specialists,
    reject_if: -> (ucs) { ucs[:specialist_id].blank? },
    allow_destroy: true

  has_many :controlled_specialists,
    through: :user_controls_specialists,
    source: :specialist,
    class_name: "Specialist"

  has_many :user_controls_clinics, dependent: :destroy
  accepts_nested_attributes_for :user_controls_clinics,
    reject_if: -> (ucc) { ucc[:clinic_id].blank? },
    allow_destroy: true
  has_many :controlled_clinics,
    through: :user_controls_clinics,
    source: :clinic,
    class_name: "Clinic"

  has_many :specialization_options, foreign_key: "owner_id"

  has_many :specializations_owned,
    through: :specialization_options,
    class_name: "Specialization",
    source: :specialization

  has_many :subscriptions, dependent: :destroy

  has_many :contacts

  has_one :mask, dependent: :destroy, class_name: "UserMask"

  delegate :with_activity, to: :subscriptions, prefix: true

  after_touch :flush_cache

  default_scope { order('users.name') }

  attr_accessible :name,
    :role,
    :active,
    :division_ids,
    :divisions,
    :user_controls_specialists_attributes,
    :user_controls_clinics_attributes,
    :password,
    :password_confirmation,
    :email,
    :email_confirmation,
    :agree_to_toc,
    :type_mask,
    :persist_in_demo,
    :last_request_format_key

  ROLE_LABELS = {
    "user" => "User",
    "admin" => "Administrator",
    "super" => "Super Administrator",
    "introspective" => "Limited-Access User"
  }

  def self.seed(args)
    email = args[:email]
    password = args[:password]
    division_id = args[:division_id]
    role = args[:role]
    name = args[:name]

    create!(
      email: email,
      email_confirmation: email,
      password: password,
      password_confirmation: password,
      role: role,
      type_mask: 4,
      name: name
    ).user_divisions.create(division_id: division_id)
  end

  def self.user
    where("users.role = 'user'")
  end

  def self.developer
    where(is_developer: true)
  end

  def self.active_user
    where(
      "users.role = (?) AND users.active = (?) "\
        "AND COALESCE(users.email,'') != ''",
      "user",
      true
    )
  end

  def self.active_introspective
    where(
      "users.role = (?) AND users.active = (?) "\
        "AND COALESCE(users.email,'') != ''",
      "introspective",
      true
    )
  end

  def self.authorized_user
    user.active.activated
  end

  def self.activated
    where("users.email IS NOT NULL AND users.email != ''")
  end

  def self.admin_only
    where("users.role = 'admin'")
  end

  def self.active_admin_only
    where(
      "users.role = 'admin' AND users.active = (?) AND COALESCE(users.email,'') != ''",
      true
    )
  end

  def self.admin
    where("users.role = 'admin' OR users.role = 'super'")
  end

  def self.super_admin
    where("users.role = 'super'")
  end

  def self.active_super_admin
    where(
      "users.role = 'super' AND users.active = (?) AND COALESCE(users.email,'') != ''",
      true
    )
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

  def self.with_subscriptions
    joins(:subscriptions).includes(:subscriptions).admin
  end

  def self.in_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(:user_divisions).
      where('"division_users"."division_id" IN (?)', division_ids)
  end

  def self.all_user_division_groups
    all.map{ |u| u.divisions.map{ |d| d.id } }.uniq
  end

  def self.all_user_division_groups_cached
    Rails.cache.fetch("all_user_division_groups", expires_in: 6.hours) do
        self.all_user_division_groups
      end
  end

  def self.division_groups_for(*divisions)
    division_ids = divisions.map(&:id)

    User.
      all_user_division_groups_cached.
      select do |group|
        division_ids.any?{ |id| group.include?(id) }
      end
  end

  def flush_cache
    Rails.cache.delete("all_user_division_groups")
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    PasswordResetMailer.password_reset_instructions(self).deliver
  end

  LAST_REQUEST_FORMATS = {
    1 => :relative,
    2 => :absolute
  }

  def last_request_format
    LAST_REQUEST_FORMATS[last_request_format_key]
  end

  def active?
    active
  end

  def pending?
    self.email.blank?
  end

  def adjusted_type_mask
    admin_or_super? ? 0 : type_mask
  end

  def validate_signup
    # we add validations for agree_to_toc here so that other parts of the user
    # forms don't break from this field being validated
    valid?
    errors.add(:agree_to_toc, "must be agreed to") if agree_to_toc.blank?
  end

  def subscriptions_by_interval_and_target(interval, target_klass)
    subscriptions.where(interval: interval, target_class: target_klass)
  end

  TYPES = {
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
    User::TYPES[type_mask]
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      saved_token = SecureRandom.hex(4)
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
      does_own |= SpecializationOption.
        find_by(specialization_id: specialization.id, owner_id: self.id).
        present?
    end
    does_own
  end

  def self.csv_import(file, divisions, type_mask, role)
    users = []
    CSV.foreach(file.path) do |row|
      user = User.new(
        name: row[0],
        divisions: divisions,
        type_mask: type_mask,
        role: role
      )
      # so we can avoid setting up with emails or passwords
      if user.save validate: false
        users << user
      else
        puts "ERROR SETTING UP #{row[0]}"
      end
    end
    users
  end

  def self.safe_find(id, fallback_klass = UnknownUser)
    where(id: id).first || fallback_klass.new
  end

  def label
    name
  end

  def divisions_referral_cities(specialization)
    as_divisions.map do |division|
      division.local_referral_cities(specialization)
    end.flatten.uniq
  end

  def customized_city_rankings?
    as_divisions.first.use_customized_city_priorities?
  end

  def city_rankings
    as_divisions.first.city_rankings
  end

  def known?
    true
  end

  def reporting_divisions
    if as_super_admin?
      Division.except_provincial
    else
      as_divisions.except_provincial
    end
  end

  def authenticated?
    true
  end

  [
    :divisions,
    :super_admin?,
    :admin?,
    :admin_or_super?,
    :user?,
    :introspective?,
    :role_label,
    :role,
    :administering
  ].each do |method_name|
    define_method "as_#{method_name}" do
      if mask.present? && mask.persisted?
        mask.send(method_name)
      else
        send(method_name)
      end
    end
  end

  def can_assign_roles
    super_admin? ? User::ROLE_LABELS : User::ROLE_LABELS.except("super")
  end

  def as_can_assign_roles
    as_super_admin? ? User::ROLE_LABELS : User::ROLE_LABELS.except("super")
  end

  def can_assign_divisions
    super_admin? ? Division.all: divisions
  end

  def as_can_assign_divisions
    as_super_admin? ? Division.all: as_divisions
  end

  def division_id
    divisions.first.try(:id) || -1
  end

  def viewed_controlled_specialist!(specialist)
    specialist.
      user_controls_specialists.
      where(user_id: self.id).
      update_all(last_visited: DateTime.current)
  end

  def viewed_controlled_clinic!(clinic)
    clinic.
      user_controls_clinics.
      where(user_id: self.id).
      update_all(last_visited: DateTime.current)
  end

  def divisions_list
    as_divisions.
      to_sentence(SentenceHelper.normal_weight_sentence_connectors).
      html_safe
  end

  def owners
    if divisions.any?
      divisions.map(&:primary_contacts).flatten
    else
      Division.provincial.primary_contacts
    end
  end
end
