class Subscription < ActiveRecord::Base
  #attr_accessible :interval, :user_id, :classification, :content_item, :item_type
  serialize :news_type

  #before_action save_subscription_news_item_types

  belongs_to :user

  has_and_belongs_to_many :divisions, join_table: :subscription_divisions

  has_many :news_items, through: :divisions #unsure if will use this

  has_and_belongs_to_many :sc_categories, join_table: :subscription_sc_categories

  has_many :subscription_news_item_types, dependent: :destroy # not a join table with news_item, only stores NewsItem::TYPE_HASH integer

  has_many :subscription_specializations, dependent: :destroy
  has_many :specializations, through: :subscription_specializations

  scope :daily,   -> {where(interval: 1)}
  scope :weekly,  -> {where(interval: 2)}
  scope :monthly, -> {where(interval: 3)}

  accepts_nested_attributes_for :divisions
  accepts_nested_attributes_for :sc_categories
  accepts_nested_attributes_for :specializations
  accepts_nested_attributes_for :subscription_news_item_types


  NEWS_ITEM_TYPE_HASH = NewsItem::TYPE_HASH

  #Update Classifications
  NEWS_UPDATES = 1
  RESOURCE_UPDATES = 2

  UPDATE_CLASSIFICATION_HASH = {
    NEWS_UPDATES => "News Updates",
    RESOURCE_UPDATES => "Resource Updates"
  }

  INTERVAL_DAILY = 1
  INTERVAL_WEEKLY = 2
  INTERVAL_MONTHLY = 3

  INTERVAL_HASH = {
    INTERVAL_DAILY => "Daily",
    INTERVAL_WEEKLY => "Weekly",
    INTERVAL_MONTHLY => "Monthly"
  }

  def interval_type
    INTERVAL_HASH[interval]
  end

  def self.classifications
    UPDATE_CLASSIFICATION_HASH.map{|k, v|  v}
  end

  def news_type_masks
    news_type.reject(&:empty?).map{|nt| nt.to_i}
  end

  def news_type_masks_strings
    news_type_masks.map{|nt| Subscription::NEWS_ITEM_TYPE_HASH[nt]}
  end

  def self.news_update
    UPDATE_CLASSIFICATION_HASH[NEWS_UPDATES]
  end

  def self.resource_update
    UPDATE_CLASSIFICATION_HASH[RESOURCE_UPDATES]
  end

  def interval_to_datetime
    case interval
    when ::Subscription::INTERVAL_DAILY
      return 1.days.ago
    when ::Subscription::INTERVAL_WEEKLY
      return 1.weeks.ago
    when ::Subscription::INTERVAL_MONTHLY
      return 1.months.ago
    end
  end
end
