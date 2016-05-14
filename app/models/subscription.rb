class Subscription < ActiveRecord::Base
  attr_accessible :sc_category_ids,
    :specialization_ids,
    :news_type,
    :division_ids,
    :sc_item_format_type,
    :classification,
    :interval,
    :user_id

  serialize :news_type
  serialize :sc_item_format_type

  validates :classification, :interval, presence: true

  belongs_to :user

  has_many :subscription_divisions, dependent: :destroy
  has_many :divisions,
    through: :subscription_divisions,
    source: :division,
    class_name: "Division"

  has_many :subscription_sc_categories, dependent: :destroy
  has_many :sc_categories, through: :subscription_sc_categories

  has_many :subscription_specializations, dependent: :destroy
  has_many :specializations, through: :subscription_specializations

  scope :immediate, -> {where(interval: INTERVAL_IMMEDIATELY)}

  scope :resources, -> {where(classification: resource_update)}
  scope :news,      -> {where(classification: news_update)}

  scope :in_divisions, ->(division){
    joins(:divisions).
      where("subscription_divisions.division_id" => Array.wrap(division).
      map(&:id)).
      uniq
  }
  scope :in_sc_categories, ->(sc_category){
    joins(:subscription_sc_categories).
      where(subscription_sc_categories: {
        sc_category_id: Array.wrap(sc_category).map(&:id)
      } ).
      uniq
  }


  accepts_nested_attributes_for :divisions
  accepts_nested_attributes_for :sc_categories
  accepts_nested_attributes_for :specializations

  SC_ITEM_FORMAT_TYPE_HASH = ScItem::FILTER_FORMAT_HASH

  NEWS_ITEM_TYPE_HASH = NewsItem::TYPE_HASH

  NEWS_UPDATES     = 1
  RESOURCE_UPDATES = 2

  TARGET_TYPES = {
    NEWS_UPDATES     => "News Updates".freeze,
    RESOURCE_UPDATES => "Resource Updates".freeze
  }

  INTERVAL_IMMEDIATELY = 1
  INTERVAL_DAILY       = 2
  INTERVAL_WEEKLY      = 3
  INTERVAL_MONTHLY     = 4

  INTERVAL_LABELS = {
    INTERVAL_IMMEDIATELY => "Immediately".freeze,
    INTERVAL_DAILY       => "Daily".freeze,
    INTERVAL_WEEKLY      => "Weekly".freeze,
    INTERVAL_MONTHLY     => "Monthly".freeze
  }

  def self.classifications
    TARGET_TYPES.map{ |k, v|  v }
  end

  def news_type_masks
    return "" if news_type.blank?
    news_type.reject(&:empty?).map(&:to_i)
  end

  def news_types_pluralized
    return "" if news_type.blank?
    news_type_strings.map(&:pluralize)
  end

  def news_type_strings
    return "" if news_type.blank?
    news_type_masks.map{ |nt| Subscription::NEWS_ITEM_TYPE_HASH[nt] }
  end

  def news_type_present?
    return false if news_type.blank?
    news_type.reject(&:blank?).present?
  end

  def self.news_update
    TARGET_TYPES[NEWS_UPDATES]
  end

  def self.resource_update
    TARGET_TYPES[RESOURCE_UPDATES]
  end

  def interval_start_datetime
    case interval
    when ::Subscription::INTERVAL_IMMEDIATELY
      raise "No start time"
    when ::Subscription::INTERVAL_DAILY
      return 1.days.ago
    when ::Subscription::INTERVAL_WEEKLY
      return 1.weeks.ago
    when ::Subscription::INTERVAL_MONTHLY
      return 1.months.ago
    end
  end

  def self.interval_period(interval_key)
    case interval_key
    when ::Subscription::INTERVAL_IMMEDIATELY
      return "just now"
    when ::Subscription::INTERVAL_DAILY
      return "today"
    when ::Subscription::INTERVAL_WEEKLY
      return "this week"
    when ::Subscription::INTERVAL_MONTHLY
      return "this month"
    end
  end

  def interval_period
    self.class.interval_period(interval_key)
  end

  def interval_to_words
    INTERVAL_LABELS[interval]
  end

  def specializations_comma_separated
    specializations.map(&:name).join(", ")
  end

  def news_item_type_hash_array
    news_type.
      reject(&:blank?).
      map(&:to_i).
      map{ |n| Subscription::NEWS_ITEM_TYPE_HASH[n] }
  end

  def sc_item_format_type_hash_array
    sc_item_format_type.
      reject(&:blank?).
      map(&:to_i).
      map{ |n| Subscription::SC_ITEM_FORMAT_TYPE_HASH[n] }
  end

  def news_update?
    classification == TARGET_TYPES[NEWS_UPDATES]
  end

  def resource_update?
    classification == TARGET_TYPES[RESOURCE_UPDATES]
  end

  def activities
    scope = SubscriptionActivity.
      by_target_type(classification).
      by_divisions(divisions).
      order("activities.created_at DESC")

    if interval != INTERVAL_IMMEDIATELY
      scope = scope.where("activities.created_at > (?)", interval_start_datetime)
    end

    if news_update?
      scope.
        by_news_item_type(news_type)
    elsif resource_update?
      scope = scope.
        by_sc_item_format_type(sc_item_format_type).
        select do |activity|
          sc_categories.include?(activity.trackable.root_category)
        end

      if specializations.any?
        scope.select do |activity|
          (activity.trackable.specializations & specializations).any?
        end
      else
        scope
      end
    end
  end
end
