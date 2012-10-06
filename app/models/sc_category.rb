class ScCategory < ActiveRecord::Base
  attr_accessible :name, :show_on_front_page, :show_as_dropdown, :display_mask, :sort_order, :parent_id, :searchable
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  has_many :sc_items
  
  has_many :featured_contents, :dependent => :destroy
  has_many :featured_sc_items, :through => :featured_contents, :source => :sc_item, :class_name => "ScItem"
  
  has_ancestry
  
  default_scope order('sc_categories.sort_order')
  
  DISPLAY_HASH = {
    2 => "In global navigation",
    4 => "In global navigation and filterable on specialty pages",
    1 => "Filterable on specialty pages",
    3 => "Inline on specialty pages"
  }
  
  def display
    ScCategory::DISPLAY_HASH[display_mask]
  end
  
  def self.global_nav
    where("sc_categories.display_mask IN (?) AND sc_categories.ancestry is null", [2,4])
  end
  
  def self.specialty
    where("sc_categories.display_mask IN (?) AND sc_categories.ancestry is null", [1,3,4])
  end
  
  def self.searchable
    where("sc_categories.searchable = ?", true)
  end

  def inline?
    display_mask == 3
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

  def all_sc_items
    items = sc_items
    self.children.each do |child|
      items += child.all_sc_items
    end
    items
  end

  def sc_items_for_specialization(specialization)
    items = sc_items.for_specialization(specialization)
    self.children.each do |child|
      items += child.sc_items.for_specialization(specialization)
    end
    items
  end

  def sc_items_for_procedure_specialization(procedure_specialization)
    items = sc_items.for_procedure_specialization(procedure_specialization)
    self.children.each do |child|
      items += child.sc_items.for_procedure_specialization(procedure_specialization)
    end
    items
  end
end
