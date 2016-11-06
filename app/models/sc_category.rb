class ScCategory < ActiveRecord::Base

  attr_accessible :name,
    :show_on_front_page,
    :index_display_format,
    :in_global_navigation,
    :filterable,
    :sort_order,
    :parent_id,
    :searchable,
    :evidential

  validates_presence_of :name, on: :create, message: "can't be blank"

  has_many :sc_items

  has_many :featured_contents, dependent: :destroy

  has_and_belongs_to_many :subscriptions,
    join_table: :subscription_sc_categories

  has_ancestry

  default_scope { order('sc_categories.sort_order, sc_categories.name') }

  scope :front_page, -> { where(show_on_front_page: true) }

  def self.front_page_for_divisions(divisions)
    joins(featured_contents: [ :division, :sc_item]).
      where("divisions.id IN (?)", divisions.map(&:id)).
      where("sc_items.title IS NOT NULL").
      uniq
  end

  DISPLAY_HASH = {
    0 => "Tabular rows on specialty pages",
    1 => "Inline articles on specialty pages"
  }

  def self.all_parents
    all.reject{ |category| category.parent.present? }
  end

  def self.all_for_subscription
    all_parents.reject do |category|
      category.name.include?("Inactive") || category.name.include?("Inline")
    end
  end

  def self.with_items_borrowable_by_division(division)
    all.reject do |category|
      category.parent.present? ||
        (category.items_borrowable_by_division(division)).none?
    end
  end

  def self.by_name(name)
    ScCategory.where(name: name).first
  end

  def featured_for_divisions(divisions)
    featured_contents.
      in_divisions(divisions).
      order("created_at").
      includes(:sc_item).
      map(&:sc_item).
      reject(&:blank?)
  end

  def self.global_resources_dropdown(user_divisions)
    GenerateResourcesDropdown.exec(user_divisions)
  end

  def self.with_items_for_divisions(divisions)
    find_by_sql([<<-SQL, { division_ids: divisions.map(&:id) }])
      SELECT DISTINCT ON ("sc_categories"."id") "sc_categories".*
      FROM "sc_categories"
      INNER JOIN "sc_items"
      ON "sc_categories"."id" = "sc_items"."sc_category_id"
      LEFT JOIN "division_display_sc_items"
      ON "division_display_sc_items"."sc_item_id" = "sc_items"."id"
      WHERE "sc_items"."division_id" IN (:division_ids)
      OR (
        "division_display_sc_items"."division_id" IN (:division_ids) AND
        "sc_items"."borrowable" = 't'
      )
    SQL
  end

  def self.specialty
    where(
      "sc_categories.index_display_format = '1' OR sc_categories.filterable "\
        "AND sc_categories.ancestry IS NULL"
    )
  end

  def self.searchable
    where(searchable: true)
  end

  def inline?
    index_display_format == 1
  end

  def full_name
    if parent.present?
      parent.name + ": " + name
    else
      name
    end
  end

  def all_borrowable_sc_items
    subtree.inject([]) do |memo, category|
      memo + (category.
        sc_items.
        includes_specialization_data.
        includes([:sc_category, :division]).
        borrowable
      )
    end
  end

  def all_owned_sc_items_in_divisions(divisions)
    items = sc_items.owned_by_divisions(divisions)
    self.children.each do |child|
      items += child.all_owned_sc_items_in_divisions(divisions)
    end
    items
  end

  def all_borrowed_sc_items_in_divisions(divisions)
    items = sc_items.borrowed_by_divisions(divisions)
    self.children.each do |child|
      items += child.all_borrowed_sc_items_in_divisions(divisions)
    end
    items
  end

  def all_sc_items_in_divisions(divisions, options = {})
    if options[:exclude_subcategories]
      scope = [ self ]
    else
      scope = subtree.includes(:sc_items)
    end

    scope.inject([]) do |memo, sc_category|
      memo + sc_category.sc_items.all_in_divisions(divisions)
    end
  end

  def all_sc_items_for_specialization_in_divisions(specialization, divisions)
    items = sc_items.for_specialization_in_divisions(specialization, divisions)
    self.children.each do |child|
      items += child.
        all_sc_items_for_specialization_in_divisions(specialization, divisions)
    end
    items
  end

  def items_borrowable_by_division(division)
    all_borrowable_sc_items - division.borrowable_sc_items
  end
end
