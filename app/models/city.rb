class City < ActiveRecord::Base
  attr_accessible :name, :province_id, :hidden
  include PaperTrailable
  include ActionView::Helpers::FormOptionsHelper

  belongs_to :province
  has_many :addresses
  has_many :locations, :through => :addresses

  has_many :division_cities, :dependent => :destroy
  has_many :divisions, :through => :division_cities

  has_many :division_referral_cities

  default_scope order('cities.name')

  validates_presence_of :name, :on => :create, :message => "can't be blank"

  # # # Caching methods
  after_commit :flush_cached_find

  PRIORITY_SETTINGS = 3
  def self.priority_setting_options
    (1..PRIORITY_SETTINGS).map do |t|
      [t, t]
    end
  end

  def self.options_for_priority_select(division)
    not_hidden.map do |city|
      {
        city_name: city.name,
        city_id: city.id,
        options_for_select: city.options_for_priority_select(division)
      }
    end
  end

  # def self.all_cached
  #   Rails.cache.fetch('City.all') { all }
  # end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  def self.all_formatted_for_select
    self.all.map(&:formatted_for_select)
  end

  def flush_cached_find
    Rails.cache.delete([self.class.name, id])
  end
  # # #

  def to_s
    self.name
  end

  def division_referral_city(division)
    division_referral_cities.where(division_id: division.id).first
  end

  def formatted_for_select
    ["#{self.name}, #{self.province.symbol}", self.id]
  end

  def self.in_divisions(divisions)
    division_ids = divisions.map{ |division| division.id }
    joins('INNER JOIN "division_cities" ON "cities".id = "division_cities".city_id').where('"division_cities".division_id IN (?)', division_ids).uniq
  end

  def self.in_progress_for_division_and_specialization(division, specialization)
    joins('INNER JOIN "division_cities" ON "cities".id = "division_cities".city_id INNER JOIN "specialization_options" ON "specialization_options".division_id = "division_cities".division_id').where('"division_cities".division_id = (?) AND "specialization_options".specialization_id = (?) AND "specialization_options".in_progress = (?)', division.id, specialization.id, true)
  end

  def self.not_in_progress_for_division_local_referral_area_and_specialization(division, specialization)
    joins('INNER JOIN "division_referral_cities" ON "division_referral_cities".city_id = "cities".id INNER JOIN "division_referral_city_specializations" ON "division_referral_cities".id = "division_referral_city_specializations".division_referral_city_id INNER JOIN "specialization_options" ON "specialization_options".division_id = "division_referral_cities".division_id AND "specialization_options".specialization_id = "division_referral_city_specializations".specialization_id').where('"division_referral_city_specializations".specialization_id = (?) AND "division_referral_cities".division_id = (?) AND "specialization_options".in_progress = (?)', specialization.id, division.id, false).uniq
  end

  def self.for_user_in_specialization(user, specialization)
    Rails.cache.fetch([user.cache_key, specialization.cache_key], expires_in: 7.days) do
      #user defined
      per_user = joins('INNER JOIN "user_cities" ON "user_cities".city_id = "cities".id INNER JOIN "user_city_specializations" ON "user_cities".id = "user_city_specializations".user_city_id').where('"user_city_specializations".specialization_id = (?) AND "user_cities".user_id = (?)', specialization.id, user.id)
      return per_user if per_user.present?

      #user is in division which has cities for specialization
      per_specialty = joins('INNER JOIN "division_referral_cities" ON "division_referral_cities".city_id = "cities".id INNER JOIN "division_referral_city_specializations" ON "division_referral_cities".id = "division_referral_city_specializations".division_referral_city_id INNER JOIN "division_users" ON "division_users".division_id = "division_referral_cities".division_id').where('"division_referral_city_specializations".specialization_id = (?) AND "division_users".user_id = (?)', specialization.id, user.id)  # DevNote: flagged by heroku as time consuming query: 29% (Time cons.), 2ms (Avg. time), 38/min (Throughput), 0ms (I/O time)
      return per_specialty if per_specialty.present?

      #user is in division which has default cities
      divisional = joins('INNER JOIN "division_cities" ON "division_cities".city_id = "cities".id INNER JOIN "division_users" ON "division_users".division_id = "division_cities".division_id').where('"division_users".user_id = (?)', user.id)
      return divisional
    end

    #^^^ refactored for performance from below:
    # if per_user.present?
    #   return per_user
    # elsif per_specialty.present?
    #   return per_specialty
    # else
    #   return divisional
    # end
  end

  def self.not_hidden
    where("cities.hidden = (?)", false)
  end

  def options_for_priority_select(division)
    if division.new_record?
      options_for_select(self.class.priority_setting_options, PRIORITY_SETTINGS)
    else
      division_referral_city(division).try(:options_for_priority_select) ||
        options_for_select(self.class.priority_setting_options, PRIORITY_SETTINGS)
    end
  end
end
