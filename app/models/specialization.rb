class Specialization < ActiveRecord::Base
  attr_accessible :name, :member_name, :label_name, :suffix, :in_progress, :specialization_options_attributes, :open_to_clinic

  include PaperTrailable

  has_many :specialist_specializations, :dependent => :destroy
  has_many :specialists, :through => :specialist_specializations

  has_many :clinic_specializations, :dependent => :destroy
  has_many :clinics, :through => :clinic_specializations

  has_many :procedure_specializations, :dependent => :destroy, :conditions => { "mapped" => true }
  has_many :procedures, :through => :procedure_specializations, :order => 'name ASC'

  has_many :sc_item_specializations, :dependent => :destroy
  has_many :sc_items, :through => :sc_items_specializations

  has_many :specialization_options, :dependent => :destroy
  accepts_nested_attributes_for :specialization_options
  has_many :owners, :through => :specialization_options, :class_name => "User"
  has_many :content_owners, :through => :specialization_options, :class_name => "User"

  has_many :division_referral_city_specializations, :dependent => :destroy

  after_commit :flush_cache
  after_touch  :flush_cache

  default_scope order('specializations.name')

  # # # # # # CACHING METHODS

  def self.cache_key
    max_updated_at = maximum(:updated_at).try(:utc).try(:to_s, :number)
    sum_of_ids = limit(100).pluck(:id).try(:compact).inject{|sum, id| sum + id }
    "specializations/all-#{count}-#{max_updated_at}-#{sum_of_ids}"
    # since cache_key can act on a subset of Specialization records; sum_of_ids was added to reduce the chance of an incorrect cache hit should two collections ever have matching count / max updated_at values
  end

  def self.all_cached
    @_all_specializations_cached ||= Rails.cache.fetch([name, "all_specializations"], expires_in: 6.hours) {self.all}
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]){find(id)}
  end

  def self.refresh_cache
    Rails.cache.write([name, "all_specializations"], self.all)
    SpecialistOffice.all.each do |office|
      Rails.cache.write([office.class.name, office.id], SpecialistOffice.find(office.id))
    end
  end

  def flush_cache #called during after_commit or after_touch
    Rails.cache.delete([self.class.name, "all_specializations"])
    Rails.cache.delete([self.class.name, self.id])
  end
  # # # # # #

  def self.complete_in(divisions)
    joins("specialization_options ON specialization_options.id = specializations.id").
      where(
        "specialization_options.division_id IN (?) AND specialization_options.in_progress = '0'",
        divisions.map(&:id)
      )
  end

  def self.has_family_practice?
    all.include?(Specialization.find_by_name("Family Practice"))
  end

  def self.in_progress_for_divisions(divisions)
    joins(:specialization_options).
      where(
        "specialization_options.division_id IN (?) AND specialization_options.in_progress = (?)",
        divisions.map(&:id),
        true
      )
  end

  def self.not_in_progress_for_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(:specialization_options).where('"specialization_options"."division_id" IN (?) AND "specialization_options"."in_progress" = (?)', division_ids, false)
  end

  def self.new_for_divisions(divisions)
    division_ids = divisions.map{ |d| d.id }
    joins(:specialization_options).where('"specialization_options"."division_id" IN (?) AND "specialization_options"."is_new" = (?)', division_ids, true)
  end

  def not_fully_in_progress
    specialization_options.reject{ |so| so.in_progress }.length > 0
  end

  def fully_in_progress
    specialization_options.reject{ |so| so.in_progress }.length == 0
  end

  def fully_in_progress_for_divisions(divisions)
    (specialization_options.for_divisions(divisions).length > 0) && (specialization_options.for_divisions(divisions).reject{ |so| so.in_progress }.length == 0)
  end

  def in_progress?(divisions = [])
    scoped_options =
      if divisions.any?
        specialization_options.for_divisions(divisions)
      else
        specialization_options
      end

    scoped_options.any? &&
      scoped_options.all?(&:in_progress?)
  end

  def new_for_divisions(divisions)
    specialization_options.for_divisions(divisions).is_new.length > 0
  end

  def open_to_tab_for_divisions(divisions)
    so = specialization_options.for_divisions(divisions)
    if so.length == 0
      return "specialists"
    else
      #we pick the first division. not neceissarly correct, but it will do.
      so.first.open_to
    end
  end

  def arranged_procedure_specializations(procedure_specializations_scope = nil)
    scope = procedure_specializations

    if procedure_specializations_scope.present?
      scope = scope.send(procedure_specializations_scope)
    end

    scope.
      mapped.
      has_procedure.
      includes(:procedure).
      arrange(order: 'procedures.name')
  end

  def token
    if self.saved_token
      return self.saved_token
    else
      update_column(:saved_token, SecureRandom.hex(16)) #avoid callbacks / validation as we don't want to trigger a sweeper for this
      return self.saved_token
    end
  end

  def no_division_clinics?
    no_division_clinics.any?
  end

  def no_division_clinics
    @no_division_clinics ||= clinics.includes_location_data.reject do |clinic|
      clinic.cities.length > 0
    end.sort do |a,b|
      a.name <=> b.name
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

  def in_progress_for_division?(division)
    specialization_options.where(division_id: division.id).in_progress?
  end

  def complete_cities(specialization)
    Division.all.inject(City.all) do |memo, division|
      if in_progress_for_division?(division)
        memo - division.cities
      else
        memo
      end
    end
  end
end
