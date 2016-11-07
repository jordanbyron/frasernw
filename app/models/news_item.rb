class NewsItem < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  validates :owner_division_id, presence: true

  attr_accessible :owner_division_id,
    :title,
    :body,
    :breaking,
    :start_date,
    :end_date,
    :show_start_date,
    :show_end_date,
    :type_mask,
    :division_ids

  belongs_to :owner_division, class_name: "Division"
  has_many :divisions, through: :division_display_news_items
  has_many :division_display_news_items, dependent: :destroy
  has_one :demoable_news_item, dependent: :destroy

  def self.not_demoable
    joins(<<-SQL)
      FULL OUTER JOIN demoable_news_items
      ON demoable_news_items.news_item_id = news_items.id
      WHERE demoable_news_items.id IS NULL
    SQL
  end

  def self.demoable
    joins(:demoable_news_item)
  end


  def self.permitted_division_assignments(user)
    if user.as_super_admin?
      Division.all
    else
      user.as_divisions
    end
  end

  def self.bust_cache_for(*divisions)
    RecacheLatestUpdatesInDivisions.call(
      division_groups: User.division_groups_for(*divisions),
      delay: true
    )
    User.division_groups_for(*divisions).each do |division_group|
      ExpireFragment.call(
        "front_#{Specialization.cache_key}_#{division_group.join('_')}"
      )
    end
  end

  def demoable!
    create_demoable_news_item
  end

  def demoable?
    demoable_news_item.present?
  end

  def copyable_to(user)
    self.class.permitted_division_assignments(user) - [ owner_division ]
  end

  def copy_to(division, current_user)
    return false unless (
      current_user.as_super_admin? ||
        current_user.as_divisions.include?(division)
    )

    NewsItem.create(
      self.attributes.except("id", "created_at", "updated_at", "parent_id").
        merge(owner_division_id: division.id)
    ).display_in_divisions!([ division ], current_user)
  end

  def label
    title.presence || titleized_body
  end
  def borrowing_divisions
    divisions - [ owner_division ]
  end

  def user_can_unborrow?(user, division)
    self.class.permitted_division_assignments(user).include?(division) &&
      division != owner_division
  end

  def check_assignment_permissions(divisions, user)
    divisions.all? do |division|
      self.class.permitted_division_assignments(user).include?(division)
    end
  end

  def titleized_body
    truncate(
      ActionView::Base.full_sanitizer.sanitize(
        BlueCloth.new(body).to_html
      ),
      :length => 60,
      :separator => ' '
    )
  end

  def date
    if (
      start_date_full.present? &&
      end_date_full.present? &&
      (start_date.to_s != end_date.to_s)
    )
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
    TYPE_BREAKING                 => "Breaking News Item",
    TYPE_SPECIALIST_CLINIC_UPDATE => "Specialist / Clinic Update",
    TYPE_ATTACHMENT_UPDATE        => "Attachment Update"
  }

  def type
    TYPE_HASH[type_mask]
  end

  def join_for(division)
    division_display_news_items.where(division_id: division.id).first
  end

  def display_in_divisions!(divisions, user)
    if check_assignment_permissions(divisions, user)
      # add new
      divisions.each do |division|
        if !self.divisions.include?(division)
          self.division_display_news_items.create(
            division_id: division.id
          )
        end
      end

      # cleanup
      (NewsItem.permitted_division_assignments(user) - divisions).
        each do |division|
          self.join_for(division).try(:destroy)
        end

      # recache
      self.class.bust_cache_for(*NewsItem.permitted_division_assignments(user))

      true
    else
      false
    end
  end

  def unborrow_from(division)
    join_for(division).destroy

    self.class.bust_cache_for(division)
  end

  def self.type_hash_as_form_array
    TYPE_HASH.to_a.map {|k,v| [k.to_s, v.to_s.pluralize]}
  end

  default_scope { order('news_items.start_date DESC') }

  def self.in_divisions(divisions)
    joins(:division_display_news_items).
      where(
        "division_display_news_items.division_id IN (?)",
        divisions.map(&:id)
      )
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

  def current?
    (
      start_date.present? &&
      end_date.present? &&
      start_date <= Date.current &&
      end_date >= Date.current
    ) || (
      start_date.nil? && end_date.present? && end_date >= Date.current
    ) || (
      end_date.nil? && start_date.present? && start_date >= Date.current
    )
  end

  def self.current
    where(<<-SQL, Date.current, Date.current, Date.current, Date.current)
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
