class Subscription < ActiveRecord::Base
  attr_accessible :sc_category_ids,
    :specialization_ids,
    :news_type,
    :division_ids,
    :sc_item_format_type,
    :target_class,
    :interval,
    :user_id

  serialize :news_type
  serialize :sc_item_format_type

  validates :target_class, :interval, presence: true

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

  scope :resources, -> {where(target_class: "ScItem")}
  scope :news,      -> {where(target_class: "NewsItem")}

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

  TARGET_CLASSES = {
    "ScItem" => "Content Items",
    "NewsItem" => "News Items"
  }

  TARGET_CLASSES.keys.each do |klassname|
    scope klassname.tableize, -> {where(target_class: klassname)}

    define_method "#{klassname.tableize}?" do
      target_class == klassname
    end
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

  def interval_period
    case interval
    when ::Subscription::INTERVAL_IMMEDIATELY
      raise "No period"
    when ::Subscription::INTERVAL_DAILY
      return 1.days
    when ::Subscription::INTERVAL_WEEKLY
      return 1.weeks
    when ::Subscription::INTERVAL_MONTHLY
      return 1.month
    end
  end

  def target_table_name
    target_class.tableize
  end

  def items_captured(end_datetime = DateTime.current)
    scope = target_class.constantize
    if interval != INTERVAL_IMMEDIATELY
      scope = scope.where(
        "#{target_table_name}.created_at > (?) AND #{target_table_name}.created_at < (?)",
        (end_datetime - interval_period),
        end_datetime
      )
    end

    if sc_items?
      scope = scope.
        where(division_id: divisions.map(&:id)).
        select do |sc_item|
          sc_categories.include?(sc_item.root_category) &&
            sc_item_format_type.include?(sc_item.format_type.to_s)
        end

      if specializations.any?
        scope = scope.select do |sc_item|
          (sc_item.specializations & specializations).any?
        end
      end

      scope
    elsif news_items?
      scope.
        where(type_mask: news_type).
        where(owner_division_id: divisions.map(&:id))
    end
  end

  def target_label
    TARGET_CLASSES[target_class]
  end
end
