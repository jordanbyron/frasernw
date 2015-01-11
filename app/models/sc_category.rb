class ScCategory < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model){controller && controller.current_user} #PublicActivity gem callback method

  attr_accessible :name, :show_on_front_page, :show_as_dropdown, :display_mask, :sort_order, :parent_id, :searchable
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  has_many :sc_items
  
  has_many :featured_contents, :dependent => :destroy

  has_many :subscriptions, through: :subscription_sc_categories
  has_many :subscription_sc_categories, dependent: :destroy
  
  has_ancestry
  
  default_scope order('sc_categories.sort_order, sc_categories.name')
  
  DISPLAY_HASH = {
    2 => "In global navigation",
    4 => "In global navigation and filterable on specialty pages",
    5 => "In global navigation and inline on specialty pages",
    1 => "Filterable on specialty pages",
    3 => "Inline on specialty pages"
  }
  
  def display
    ScCategory::DISPLAY_HASH[display_mask]
  end
  
  def self.global_resources_dropdown
    where("sc_categories.display_mask IN (?) AND sc_categories.show_as_dropdown = (?)", [2,4,5], true)
  end
  
  def self.global_navbar
    where("sc_categories.display_mask IN (?) AND sc_categories.show_as_dropdown = (?)", [2,4,5], false)
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

  def all_sc_items_in_divisions(divisions, options = {})
    options[:exclude_subcategories] ||= false;
    items = sc_items.all_in_divisions(divisions)
    if (!options[:exclude_subcategories])
      self.children.each do |child|
        items += child.all_sc_items_in_divisions(divisions, options)
      end
    end
    items
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
