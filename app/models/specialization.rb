class Specialization < ActiveRecord::Base
  attr_accessible :name,
    :member_name,
    :label_name,
    :suffix,
    :specialization_options_attributes,
    :open_to_clinic

  include PaperTrailable

  has_many :specialist_specializations, dependent: :destroy
  has_many :specialists, through: :specialist_specializations

  has_many :clinic_specializations, dependent: :destroy
  has_many :clinics, through: :clinic_specializations

  has_many :procedure_specializations,
    dependent: :destroy
  has_many :procedures, -> { order 'procedures.name ASC' },
    through: :procedure_specializations

  has_many :sc_item_specializations, dependent: :destroy
  has_many :sc_items, through: :sc_item_specializations

  has_many :specialization_options, dependent: :destroy
  accepts_nested_attributes_for :specialization_options
  has_many :owners, through: :specialization_options, class_name: "User"
  has_many :content_owners,
    through: :specialization_options,
    class_name: "User"

  has_many :hidden_divisions,
    -> { where(specialization_options: { hide_from_division_users: true}) },
    through: :specialization_options,
    source: :division

  has_many :division_referral_city_specializations, dependent: :destroy
  has_many :divisional_sc_item_subscriptions

  after_commit :flush_cache
  after_touch  :flush_cache

  default_scope { order('specializations.name') }

  def self.cache_key
    max_updated_at = maximum(:updated_at).try(:utc).try(:to_s, :number)
    sum_of_ids =
      limit(100).pluck(:id).try(:compact).inject{ |sum, id| sum + id }
    "specializations/all-#{count}-#{max_updated_at}-#{sum_of_ids}"
    # since cache_key can act on a subset of Specialization records,
    # sum_of_ids was added to reduce the chance of an incorrect cache hit
    # should two collections ever have matching count / max updated_at values
  end

  def self.not_family_practice
    where("specializations.name != 'Family Practice'")
  end

  def self.all_cached
    @_all_specializations_cached ||= Rails.cache.
      fetch(
        [name, "all_specializations"],
        expires_in: 6.hours
      ) { self.all }
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  def self.refresh_cache
    Rails.cache.write([name, "all_specializations"], self.all)
    SpecialistOffice.all.each do |office|
      Rails.cache.write(
        [office.class.name, office.id],
        SpecialistOffice.find(office.id)
      )
    end
  end

  def hidden_in?(*divisions)
    specialization_options.
      where(hide_from_division_users: false).
      for_divisions(divisions).none?
  end

  def hidden_in_divisions
    specialization_options.
      includes(:division).
      where(hide_from_division_users: true).
      map(&:division)
  end

  def self.for_users_in(*divisions)
    joins(:specialization_options).where(
      '"specialization_options"."division_id" IN (?) '\
        'AND "specialization_options"."hide_from_division_users" = (?)',
      divisions.map(&:id),
      false
    ).uniq
  end

  def self.for(user)
    if user.as_admin_or_super?
      all
    else
      for_users_in(user.as_divisions)
    end
  end

  def flush_cache #called during after_commit or after_touch
    Rails.cache.delete([self.class.name, "all_specializations"])
    Rails.cache.delete([self.class.name, self.id])
  end

  def self.has_family_practice?
    all.include?(Specialization.find_by_name("Family Practice"))
  end

  def self.new_for_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(:specialization_options).where(
      '"specialization_options"."division_id" IN (?) '\
        'AND "specialization_options"."is_new" = (?)',
      division_ids,
      true
    )
  end

  def new_for_divisions?(divisions)
    specialization_options.for_divisions(divisions).is_new.length > 0
  end

  def arranged_procedure_specializations(procedure_specializations_scope = nil)
    scope = procedure_specializations

    if procedure_specializations_scope.present?
      scope = scope.send(procedure_specializations_scope)
    end

    scope.
      has_procedure.
      includes(:procedure).
      arrange(order: 'procedures.name')
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16))
      return self.saved_token
    end
  end

  def no_division_specialists?
    no_division_specialists.any?
  end

  def no_division_specialists
    @no_division_specialists ||=
      specialists.with_cities.reject do |specialist|
        specialist.cities.length > 0
      end
  end

  def filter_by_self(records)
    records.select do |record|
      record.specializations.include? self
    end
  end
end
