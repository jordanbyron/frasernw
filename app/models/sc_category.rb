class ScCategory < ActiveRecord::Base
  attr_accessible :name, :show_on_front_page, :show_as_dropdown, :display_mask, :sort_order
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  has_many :sc_items
  
  has_many :featured_contents, :dependent => :destroy
  has_many :featured_sc_items, :through => :featured_contents, :source => :sc_item, :class_name => "ScItem"
  
  default_scope order('sc_categories.sort_order')
  
  DISPLAY_HASH = {
    1 => "On specialty pages",
    2 => "In global navigation menu",
    3 => "On specialty pages and in global navigation menu"
  }
  
  def display
    ScCategory::DISPLAY_HASH[display_mask]
  end
  
  def self.global_nav
    where("sc_categories.display_mask != ?", 1)
  end
  
  def self.specialty
    where("sc_categories.display_mask != ?", 2)
  end
  
  def show_as_dropdown?
    show_as_dropdown
  end
  
  def show_on_front_page?
    show_on_front_page
  end
end
