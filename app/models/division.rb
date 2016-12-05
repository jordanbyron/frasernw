class Division < ActiveRecord::Base

  attr_accessible :name,
    :city_ids,
    :borrowed_sc_item_ids,
    :division_primary_contacts_attributes,
    :use_customized_city_priorities,
    :featured_contents_attributes

  has_many :division_cities, dependent: :destroy

  has_many :cities, through: :division_cities
  has_many :division_referral_cities, dependent: :destroy

  # # returns all cities in division's local referral area
  # e.g. d.referral_cities === d.division_referral_cities.map{ |drc| drc.city }
  has_many :referral_cities, through: :division_referral_cities, source: :city

  has_many :division_referral_city_specializations,
    through: :division_referral_cities

  has_many :division_users, dependent: :destroy
  has_many :users, through: :division_users

  has_many :division_display_sc_items, dependent: :destroy
  has_many :borrowed_sc_items,
    through: :division_display_sc_items,
    source: "sc_item",
    class_name: "ScItem"

  has_many :sc_items

  has_many :subscription_divisions, dependent: :destroy
  has_many :subscriptions, through: :subscription_divisions

  has_many :news_items, dependent: :destroy

  has_many :featured_contents, dependent: :destroy
  accepts_nested_attributes_for :featured_contents

  has_many :division_primary_contacts, dependent: :destroy
  has_many :primary_contacts,
    through: :division_primary_contacts,
    class_name: "User"
  accepts_nested_attributes_for :division_primary_contacts, allow_destroy: true

  has_many :specialization_options, dependent: :destroy
  has_one :divisional_sc_item_subscription, dependent: :destroy

  include PaperTrailable

  default_scope { order('divisions.name') }

  validates_presence_of :name, on: :create, message: "can't be blank"

  after_commit :flush_cache
  after_touch  :flush_cache

  def self.except_provincial
    where('"divisions".name != (?)', "Provincial")
  end

  def self.provincial
    where(name: "Provincial").first
  end

  def showing_specializations
    Specialization.for_users_in(self)
  end

  def flush_cache
    Division.all.each do |division|
      Rails.cache.delete([division.class.name, division.id])
    end
  end

  def admins
    (users.admin + User.super_admin).uniq
  end

  def search_data
    @search_data ||= DivisionalSearchData.new(self)
  end

  def to_s
    self.name
  end

  def specializations_referred_to(city)
    Specialization.
      joins({
        division_referral_city_specializations: {
          division_referral_city: [:city, :division]
        }
      }).
      where(cities: {id: city.id}).
      where(divisions: {id: self.id})
  end

  def local_referral_cities(specialization)
    @local_referral_cities ||= Hash.new do |h, key|
      h[key] = division_referral_city_specializations.
        includes([:specialization, { division_referral_city: :city }]).
        where(specialization_id: key).map do |drcs|
          drcs.division_referral_city.city
        end.
        reject(&:nil?)
    end
    @local_referral_cities[specialization.id]
  end

  def specialization_complete?(specialization)
    @specialization_complete ||= Hash.new do |h, key|
      h[key] = specialization_options.complete.exists?(specialization_id: key)
    end
    @specialization_complete[specialization.id]
  end

  def waittime_counts(klass)
    WaitTimeReporter.new(klass, division: self).counts
  end

  def median_waittime(klass)
    WaitTimeReporter.new(klass, division: self).median
  end

  def borrowable_sc_items
    @borrowable_sc_items ||= ScItem.borrowable_by_divisions([ self ])
  end

  def borrowed_sc_items
    @borrowed_sc_items ||= ScItem.borrowed_by_divisions([ self ])
  end

  def refer_to_encompassed_cities!(specialization)
    cities.each do |city|
      DivisionReferralCitySpecialization.find_or_create_by(
        specialization: specialization,
        division_referral_city: DivisionReferralCity.find_by(
          city: city,
          division: self
        )
      )
    end
  end

  def city_rankings(force: false)
    Rails.cache.fetch("division_city_rankings_#{id}", force: force) do
      city_ids = cities.pluck(:id)

      if use_customized_city_priorities?
        division_referral_cities.inject({}) do |memo, drc|
          memo.merge(drc.city_id => drc.priority)
        end
      else
        City.
          order("name DESC").
          each_with_index.
          inject({}) do |memo, (city, index)|
            memo.merge(city.id => index)
          end
      end
    end
  end

  def build_featured_contents!
    ScCategory.front_page.each do |category|
      (
        FeaturedContent::MAX_FEATURED_ITEMS -
        featured_contents.in_category(category).count
      ).times do
        featured_contents.build(sc_category_id: category.id)
      end
    end
  end

  def owners_for(item)
    if item.respond_to?(:specializations)
      from_specialization_options =
        if item.specializations.any?
          specialization_options.
            where(
              "specialization_options.specialization_id IN (?)",
              item.specializations.map(&:id)
            )
        else
          specialization_options
        end

      owner_type = item.is_a?(ScItem) ? :content_owner : :owner

      from_specialization_options.map(&owner_type).uniq
    else
      primary_contacts
    end.select(&:active?).select(&:admin_or_super?)
  end
end
