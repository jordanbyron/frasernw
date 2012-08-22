class ScCategory < ActiveRecord::Base
  attr_accessible :name, :show_on_front_page
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  has_many :sc_items
  
  has_many :featured_contents, :dependent => :destroy
  has_many :featured_sc_items, :through => :featured_contents, :source => :sc_item, :class_name => "ScItem"
  
  default_scope order('sc_categories.name')
  
  def show_on_front_page?
    show_on_front_page
  end
end
