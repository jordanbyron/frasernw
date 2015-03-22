class Subscription < ActiveRecord::Base
  #attr_accessible :interval, :user_id, :classification, :content_item, :item_type
  serialize :news_type

  #before_action save_subscription_news_item_types
  validates :classification, :interval, presence: true

  belongs_to :user

  has_and_belongs_to_many :divisions, join_table: :subscription_divisions

  has_many :news_items, through: :divisions #unsure if will use this

  has_and_belongs_to_many :sc_categories, join_table: :subscription_sc_categories

  has_many :subscription_news_item_types, dependent: :destroy # not a join table with news_item, only stores NewsItem::TYPE_HASH integer

  has_many :subscription_specializations, dependent: :destroy
  has_many :specializations, through: :subscription_specializations

  scope :daily,     -> {where(interval: INTERVAL_DAILY)}
  scope :weekly,    -> {where(interval: INTERVAL_WEEKLY)}
  scope :monthly,   -> {where(interval: INTERVAL_MONTHLY)}
  scope :immediate, -> {where(interval: INTERVAL_IMMEDIATELY)}

  accepts_nested_attributes_for :divisions
  accepts_nested_attributes_for :sc_categories
  accepts_nested_attributes_for :specializations
  accepts_nested_attributes_for :subscription_news_item_types


  NEWS_ITEM_TYPE_HASH = NewsItem::TYPE_HASH

  #Update Classifications
  NEWS_UPDATES = 1
  RESOURCE_UPDATES = 2

  UPDATE_CLASSIFICATION_HASH = {
    NEWS_UPDATES => "News Updates".freeze,
    RESOURCE_UPDATES => "Resource Updates".freeze
  }

  INTERVAL_IMMEDIATELY = 1
  INTERVAL_DAILY     = 2
  INTERVAL_WEEKLY    = 3
  INTERVAL_MONTHLY   = 4

  INTERVAL_HASH = {
    INTERVAL_IMMEDIATELY => "Immediately".freeze,
    INTERVAL_DAILY => "Daily".freeze,
    INTERVAL_WEEKLY => "Weekly".freeze,
    INTERVAL_MONTHLY => "Monthly".freeze
  }

  def interval_type
    INTERVAL_HASH[interval]
  end

  def self.classifications
    UPDATE_CLASSIFICATION_HASH.map{|k, v|  v}
  end

  def news_type_masks
    return "" if news_type.blank?
    news_type.reject(&:empty?).map(&:to_i)
  end

  def news_types_pluralized
    news_type_strings.map(&:pluralize)
  end

  def news_type_strings
    news_type_masks.map{|nt| Subscription::NEWS_ITEM_TYPE_HASH[nt]}
  end

  def news_type_present?
    return false if news_type.blank?
    news_type.reject(&:blank?).present?
  end

  def self.news_update
    UPDATE_CLASSIFICATION_HASH[NEWS_UPDATES]
  end

  def self.resource_update
    UPDATE_CLASSIFICATION_HASH[RESOURCE_UPDATES]
  end

  def interval_to_datetime
    case interval
    when ::Subscription::INTERVAL_IMMEDIATELY
      return 1.hours.ago
    when ::Subscription::INTERVAL_DAILY
      return 1.days.ago
    when ::Subscription::INTERVAL_WEEKLY
      return 1.weeks.ago
    when ::Subscription::INTERVAL_MONTHLY
      return 1.months.ago
    end
  end

  def interval_to_words
    case interval
    when ::Subscription::INTERVAL_IMMEDIATELY
      return "Immediately"
    when ::Subscription::INTERVAL_DAILY
      return "Daily"
    when ::Subscription::INTERVAL_WEEKLY
      return "Weekly"
    when ::Subscription::INTERVAL_MONTHLY
      return "Monthly"
    end
  end

  #decorate data
  def specializations_comma_separated
    specializations.map(&:name).join(", ")
  end

  def news_item_type_hash_array
    news_type.reject(&:blank?).map(&:to_i).map{|n| Subscription::NEWS_ITEM_TYPE_HASH[n]}
  end
end
