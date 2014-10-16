class Subscription < ActiveRecord::Base
  belongs_to :user

  has_many :subscription_divisions, dependent: :destroy
  has_many :divisions, through: :subscription_divisions

  has_many :news_items, through: :divisions #unsure if will use this

  has_many :subscription_sc_categories, dependent: :destroy
  has_many :sc_categories, through: :subscription_sc_categories

  has_many :subscription_news_item_types, dependent: :destroy # not a join table with news_item, only stores NewsItem::TYPE_HASH integer


  has_many :subscription_specializations, dependent: :destroy
  has_many :specializations, through: :subscription_specializations

  accepts_nested_attributes_for :divisions
  accepts_nested_attributes_for :specializations
  accepts_nested_attributes_for :subscription_news_item_types
  
  #Update Classifications
  NEWS_UPDATES = 1
  RESOURCE_UPDATES = 2

  UPDATE_CLASSIFICATION_HASH = {
    NEWS_UPDATES => "News Updates",
    RESOURCE_UPDATES => "Resource Updates",
  }



end
