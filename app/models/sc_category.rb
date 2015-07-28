class ScCategory < ActiveRecord::Base

  attr_accessible :name, :show_on_front_page, :show_as_dropdown, :display_mask, :sort_order, :parent_id, :searchable
  validates_presence_of :name, :on => :create, :message => "can't be blank"

  has_many :sc_items

  has_many :featured_contents, :dependent => :destroy

  has_and_belongs_to_many :subscriptions, join_table: :subscription_sc_categories
  # has_many :subscriptions, through: :subscription_sc_categories
  # has_many :subscription_sc_categories, dependent: :destroy

  has_ancestry

  default_scope order('sc_categories.sort_order, sc_categories.name')

  DISPLAY_HASH = {
    2 => "In global navigation",
    4 => "In global navigation and filterable on specialty pages",
    5 => "In global navigation and inline on specialty pages",
    1 => "Filterable on specialty pages",
    3 => "Inline on specialty pages"
  }

  def self.all_parents
    all.reject{|c| c.parent.present?}
  end

  def self.all_for_subscription
    all_parents.reject{|c| c.name == "Inactive" }
  end

  def display
    ScCategory::DISPLAY_HASH[display_mask]
  end

  def self.global_resources_dropdown(user_divisions)
    GenerateResourcesDropdown.exec(user_divisions)
  end

  def self.with_items_for_divisions(divisions)
    find_by_sql([<<-SQL, { division_ids: divisions.map(&:id) }])
      SELECT DISTINCT ON ("sc_categories"."id") "sc_categories".*
      FROM "sc_categories"
      INNER JOIN "sc_items"
      ON "sc_categories"."id" = "sc_items"."id"
      LEFT JOIN "division_display_sc_items"
      ON "division_display_sc_items"."sc_item_id" = "sc_items"."id"
      WHERE "sc_items"."division_id" IN (:division_ids)
      OR (
        "division_display_sc_items"."division_id" IN (:division_ids) AND
        "sc_items"."shareable" = 't'
      )
    SQL
  end

  def show_in_global_resources_dropdown?
    [2, 4, 5].include?(display_mask) && show_as_dropdown?
  end

  def self.global_navbar(user_divisions)
    where(
      "sc_categories.display_mask IN (?) AND sc_categories.show_as_dropdown = (?)",
      [2,4,5],
      false
    ).reject do |category|
      category.all_sc_items_in_divisions(user_divisions).blank?
    end
  end

  def self.specialty
    where("sc_categories.display_mask IN (?) AND sc_categories.ancestry is null", [1,3,4,5])
  end

  def self.searchable
    where("sc_categories.searchable = (?)", true)
  end

  INLINE_MASKS = [3,5]

  def inline?
    ScCategory::INLINE_MASKS.include? display_mask
  end

  def full_name
    if parent.present?
      parent.name + ": " + name
    else
      name
    end
  end

  def show_as_dropdown?
    show_as_dropdown
  end

  def show_on_front_page?
    show_on_front_page
  end

  def all_shareable_sc_items
    items = sc_items.shareable
    self.children.each do |child|
      items += child.all_shareable_sc_items
    end
    items
  end

  def all_owned_sc_items_in_divisions(divisions)
    items = sc_items.owned_in_divisions(divisions)
    self.children.each do |child|
      items += child.all_owned_sc_items_in_divisions(divisions)
    end
    items
  end

  def all_shared_sc_items_in_divisions(divisions)
    items = sc_items.shared_in_divisions(divisions)
    self.children.each do |child|
      items += child.all_shared_sc_items_in_divisions(divisions)
    end
    items
  end

  def all_sc_items_in_divisions(divisions)
    subtree.includes(:sc_items).inject([]) do |memo, sc_category|
      memo + sc_category.sc_items.all_in_divisions(divisions)
    end
  end

  def all_sc_items_for_specialization_in_divisions(specialization, divisions)
    items = sc_items.for_specialization_in_divisions(specialization, divisions)
    self.children.each do |child|
      items += child.all_sc_items_for_specialization_in_divisions(specialization, divisions)
    end
    items
  end

  def all_sc_items_for_procedure_in_divisions(procedure, divisions)
    items = sc_items.for_procedure_in_divisions(procedure, divisions)
    self.children.each do |child|
      items += child.all_sc_items_for_procedure_in_divisions(procedure, divisions)
    end
    items.flatten.uniq
  end
end
