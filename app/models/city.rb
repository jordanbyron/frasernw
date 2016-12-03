class City < ActiveRecord::Base
  attr_accessible :name, :province_id, :hidden
  include PaperTrailable
  include ActionView::Helpers::FormOptionsHelper

  belongs_to :province
  has_many :addresses
  has_many :locations, through: :addresses

  has_many :division_cities, dependent: :destroy
  has_many :divisions, through: :division_cities

  has_many :division_referral_cities, dependent: :destroy

  default_scope { order('cities.name') }

  validates_presence_of :name, on: :create, message: "can't be blank"

  PRIORITY_SETTINGS = 3
  def self.priority_setting_options
    (1..PRIORITY_SETTINGS).map do |t|
      [t, t]
    end
  end

  def self.options_for_priority_select(division)
    all.map do |city|
      {
        city_name: city.name,
        city_id: city.id,
        options_for_select: city.options_for_priority_select(division)
      }
    end
  end

  def self.all_formatted_for_select(scope = :presence)
    self.select(&scope).map(&:formatted_for_select)
  end

  def self.divisional_choices(user, *scope)
    if user.as_super_admin?
      all_formatted_for_select(*scope)
    else
      in_divisions(user.as_divisions).
        all_formatted_for_select(*scope)
    end
  end

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
    joins('INNER JOIN "division_cities" ON "cities".id = "division_cities".city_id').
      where('"division_cities".division_id IN (?)', division_ids).uniq
  end

  def options_for_priority_select(division)
    if division.new_record?
      options_for_select(self.class.priority_setting_options, PRIORITY_SETTINGS)
    else
      division_referral_city(division).try(:options_for_priority_select) ||
        options_for_select(self.class.priority_setting_options, PRIORITY_SETTINGS)
    end
  end

  def visible?
    !hidden?
  end
end
