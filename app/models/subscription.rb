class Subscription < ActiveRecord::Base
  #attr_accessible :interval, :user_id, :classification, :content_item, :item_type
  serialize :news_type
  serialize :sc_item_format_type

  #before_action save_subscription_news_item_types
  validates :classification, :interval, presence: true

  belongs_to :user

  has_many :subscription_divisions, dependent: :destroy
  has_many :divisions, through: :subscription_divisions, source: :division, class_name: "Division"

  has_many :subscription_sc_categories, dependent: :destroy
  has_many :sc_categories, through: :subscription_sc_categories

  has_many :subscription_specializations, dependent: :destroy
  has_many :specializations, through: :subscription_specializations

  scope :all_daily,     -> {where(interval: INTERVAL_DAILY)}
  scope :all_weekly,    -> {where(interval: INTERVAL_WEEKLY)}
  scope :all_monthly,   -> {where(interval: INTERVAL_MONTHLY)}
  scope :all_immediately, -> {where(interval: INTERVAL_IMMEDIATELY)}
  scope :all_by_date_interval, lambda { |date_interval| where(interval: date_interval)}

  scope :resources, -> {where(classification: resource_update)}
  scope :news,      -> {where(classification: news_update)}

  scope :in_divisions,     lambda {|division|    joins(:divisions).where("subscription_divisions.division_id" => Array.wrap(division).map(&:id)).uniq }
  scope :in_sc_categories, lambda {|sc_category| joins(:subscription_sc_categories).where(:subscription_sc_categories => {:sc_category_id => Array.wrap(sc_category).map(&:id)} ).uniq }


  accepts_nested_attributes_for :divisions
  accepts_nested_attributes_for :sc_categories
  accepts_nested_attributes_for :specializations

  SC_ITEM_FORMAT_TYPE_HASH = ScItem::FILTER_FORMAT_HASH

  NEWS_ITEM_TYPE_HASH = NewsItem::TYPE_HASH

  #Update Classifications
  NEWS_UPDATES     = 1
  RESOURCE_UPDATES = 2

  UPDATE_CLASSIFICATION_HASH = {
    NEWS_UPDATES => "News Updates".freeze,
    RESOURCE_UPDATES => "Resource Updates".freeze
  }

  INTERVAL_IMMEDIATELY = 1
  INTERVAL_DAILY       = 2
  INTERVAL_WEEKLY      = 3
  INTERVAL_MONTHLY     = 4

  INTERVAL_HASH = {
    INTERVAL_IMMEDIATELY => "Immediately".freeze,
    INTERVAL_DAILY => "Daily".freeze,
    INTERVAL_WEEKLY => "Weekly".freeze,
    INTERVAL_MONTHLY => "Monthly".freeze
  }

  def self.classifications
    UPDATE_CLASSIFICATION_HASH.map{|k, v|  v}
  end

  def self.with_activity(activity)
    includes(:divisions, :sc_categories).all.reject{|subscription| subscription.includes_activity?(activity) == false}
  end

  def includes_activity?(activity)
    ary = Array.new
    ary << activity
    (SubscriptionActivity.collect_activities(subscription: self) & ary).present?
  end

  def activities
    SubscriptionActivity.collect_activities(subscription: self)
  end

  # # #BEGIN news_type:
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
    news_type_masks.map{|nt| Subscription::NEWS_ITEM_TYPE_HASH[nt]}
  end

  def news_type_present?
    return false if news_type.blank?
    news_type.reject(&:blank?).present?
  end
  # # # END

  # # #BEGIN sc_item_format_type:
  def sc_item_format_type_masks
    return "" if sc_item_format_type.blank?
    sc_item_format_type.reject(&:empty?).map(&:to_i)
  end

  def sc_item_format_type_strings
    return "" if sc_item_format_type.blank?
    sc_item_format_type_masks.map{|nt| Subscription::SC_ITEM_FORMAT_TYPE_HASH[nt]}
  end

  def sc_item_format_types_pluralized
    return "" if sc_item_format_type.blank?
    sc_item_format_type_strings.map(&:pluralize)
  end

  def sc_item_format_type_present?
    return false if sc_item_format_type.blank?
    sc_item_format_type.reject(&:blank?).present?
  end
  # # # END

  def self.news_update
    UPDATE_CLASSIFICATION_HASH[NEWS_UPDATES]
  end

  def self.resource_update
    UPDATE_CLASSIFICATION_HASH[RESOURCE_UPDATES]
  end

  def interval_to_datetime # returns equivalent datetime value
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

  def interval_phrase
    case interval
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

  def interval_to_words # returns string e.g.: "Daily"
    INTERVAL_HASH[interval]
  end

  #decorate data
  def specializations_comma_separated
    specializations.map(&:name).join(", ")
  end

  def news_item_type_hash_array
    news_type.reject(&:blank?).map(&:to_i).map{|n| Subscription::NEWS_ITEM_TYPE_HASH[n]}
  end

  def sc_item_format_type_hash_array
    sc_item_format_type.reject(&:blank?).map(&:to_i).map{|n| Subscription::SC_ITEM_FORMAT_TYPE_HASH[n]}
  end
end
