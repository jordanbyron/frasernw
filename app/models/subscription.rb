class Subscription < ActiveRecord::Base
  attr_accessible :interval

  belongs_to :user

  has_many :subscription_divisions, dependent: :destroy
  has_many :divisions, through: :subscription_divisions

  has_many :news_items, through: :divisions #unsure if will use this

  has_many :subscription_sc_categories, dependent: :destroy
  has_many :sc_categories, through: :subscription_sc_categories, include: :true

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

  def self.news_update_type
    UPDATE_CLASSIFICATION_HASH[NEWS_UPDATES]
  end

  def self.resource_update_type
    UPDATE_CLASSIFICATION_HASH[RESOURCE_UPDATES]
  end
end
