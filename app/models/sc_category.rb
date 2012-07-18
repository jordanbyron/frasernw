class ScCategory < ActiveRecord::Base
  attr_accessible :name
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  
  has_many :sc_items
  
  has_many :featured_contents, :dependent => :destroy
  has_many :featured_sc_items, :through => :featured_contents, :source => :sc_item, :class_name => "ScItem"
end
