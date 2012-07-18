class Front < ActiveRecord::Base
  
  has_many :featured_contents
  has_many :sc_categories, :through => :featured_contents
  has_many :sc_items, :through => :featured_contents
  accepts_nested_attributes_for :featured_contents
  
end
