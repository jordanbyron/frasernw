class NewsItem < ActiveRecord::Base
  include PublicActivity::Model
  include FragmentExpirer
  # not used as activity is created in controller
  # tracked only: [:create], owner: ->(controller, model){controller && controller.current_user} #PublicActivity gem callback method
  has_many :activities, as: :trackable, class_name: 'SubscriptionActivity', dependent: :destroy

  attr_accessible :owner_division_id, :title, :body, :breaking, :start_date, :end_date, :show_start_date, :show_end_date, :type_mask

  belongs_to :owner_division, class_name: "Division"
  has_many :divisions, through: :division_display_news_items
  has_many :division_display_news_items, dependent: :destroy

  def date
    if start_date_full.present? && end_date_full.present? && (start_date.to_s != end_date.to_s)
      "#{start_date_full} - #{end_date_full}"
    elsif start_date_full.present?
      start_date_full
    elsif end_date_full.present?
      end_date_full
    end
  end

  def start_date_full
    if show_start_date?
      start_date_full_regardless
    else
      ""
    end
  end

  def start_date_full_regardless
    if start_date.present?
      "#{start_date.strftime('%A %B')} #{start_date.day.ordinalize}"
    else
      ""
    end
  end

  def end_date_full
    if show_end_date?
      end_date_full_regardless
    else
      ""
    end
  end

  def end_date_full_regardless
    if end_date.present?
      "#{end_date.strftime('%A %B')} #{end_date.day.ordinalize}"
    else
      ""
    end
  end

  TYPE_BREAKING                 = 1
  TYPE_DIVISIONAL               = 2
  TYPE_SHARED_CARE              = 3
  TYPE_SPECIALIST_CLINIC_UPDATE = 4
  TYPE_ATTACHMENT_UPDATE        = 5

  TYPE_HASH = {
    TYPE_DIVISIONAL               => "Divisional Update",
    TYPE_SHARED_CARE              => "Shared Care Update",
    TYPE_BREAKING                 => "Breaking News",
    TYPE_SPECIALIST_CLINIC_UPDATE => "Specialist / Clinic Update",
    TYPE_ATTACHMENT_UPDATE        => "Attachment Update"
  }

  def type
    TYPE_HASH[type_mask]
  end

  def join_for(division)
    division_display_news_items.where(division_id: division.id).first
  end

  def display_in_divisions!(*divisions)
    to_recache = divisions | self.divisions

    # add new
    divisions.each do |division|
      if !self.divisions.include?(division)
        self.division_display_news_items.create(
          division_id: division.id
        )
      end
    end

    # cleanup
    (self.divisions - divisions).each do |division|
      self.join_for(division).destroy
    end

    # recache
    User.in_divisions(to_recache).map do |user|
      user.divisions.map(&:id)
    end.uniq.each do |division_group|
      expire_fragment "latest_updates_#{division_group.join('_')}"
    end
  end

  def self.type_hash_as_form_array
    TYPE_HASH.to_a.map {|k,v| [k.to_s, v.to_s.pluralize]}
  end

  default_scope order('news_items.start_date DESC')

  def self.in_divisions(divisions)
    joins(:division_display_news_items).
      where("division_display_news_items.division_id IN (?)", divisions.map(&:id))
  end

  def self.breaking_in_divisions(divisions)
    type_in_divisions(TYPE_BREAKING, divisions)
  end

  def self.divisional_in_divisions(divisions)
    type_in_divisions(TYPE_DIVISIONAL, divisions)
  end

  def self.shared_care_in_divisions(divisions)
    type_in_divisions(TYPE_SHARED_CARE, divisions)
  end

  def self.specialist_clinic_in_divisions(divisions)
    type_in_divisions(TYPE_SPECIALIST_CLINIC_UPDATE, divisions)
  end

  def self.attachment_in_divisions(divisions)
    type_in_divisions(TYPE_ATTACHMENT_UPDATE, divisions)
  end

  def self.current
    where(<<-SQL, Date.today, Date.today, Date.today, Date.today)
      (news_items.start_date IS NOT NULL AND
        news_items.end_date IS NOT NULL AND
        news_items.start_date <= (?) AND
        news_items.end_date >= (?)) OR
      (news_items.start_date IS NULL AND
        news_items.end_date IS NOT NULL AND
        news_items.end_date >= (?)) OR
      (news_items.end_date IS NULL AND
        news_items.start_date IS NOT NULL AND
        news_items.start_date >= (?))
    SQL
  end

  def self.type_in_divisions(type, divisions)
    in_divisions(divisions).
    where(type_mask: type).
      current
  end
end
