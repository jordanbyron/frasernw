class City < ActiveRecord::Base
  attr_accessible :name, :province_id, :hidden
  has_paper_trail

  belongs_to :province
  has_many :addresses
  has_many :locations, :through => :addresses

  has_many :division_cities, :dependent => :destroy
  has_many :divisions, :through => :division_cities

  default_scope order('cities.name')

  validates_presence_of :name, :on => :create, :message => "can't be blank"

  # # # Caching methods
  after_commit :flush_cached_find

  # def self.all_cached
  #   Rails.cache.fetch('City.all') { all }
  # end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) { find(id) }
  end

  def flush_cached_find
    Rails.cache.delete([self.class.name, id])
  end
  # # #

  def to_s
    self.name
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
    #user defined
    per_user = joins('INNER JOIN "user_cities" ON "user_cities".city_id = "cities".id INNER JOIN "user_city_specializations" ON "user_cities".id = "user_city_specializations".user_city_id').where('"user_city_specializations".specialization_id = (?) AND "user_cities".user_id = (?)', specialization.id, user.id)
    #user is in division which has cities for specialization
    per_specialty = joins('INNER JOIN "division_referral_cities" ON "division_referral_cities".city_id = "cities".id INNER JOIN "division_referral_city_specializations" ON "division_referral_cities".id = "division_referral_city_specializations".division_referral_city_id INNER JOIN "division_users" ON "division_users".division_id = "division_referral_cities".division_id').where('"division_referral_city_specializations".specialization_id = (?) AND "division_users".user_id = (?)', specialization.id, user.id)
    #user is in division which has default cities
    divisional = joins('INNER JOIN "division_cities" ON "division_cities".city_id = "cities".id INNER JOIN "division_users" ON "division_users".division_id = "division_cities".division_id').where('"division_users".user_id = (?)', user.id)

    if per_user.present?
      return per_user
    elsif per_specialty.present?
      return per_specialty
    else
      return divisional
    end
  end

  def self.not_hidden
    where("cities.hidden = (?)", false)
  end
end
