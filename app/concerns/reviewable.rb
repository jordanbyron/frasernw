module Reviewable
  extend ActiveSupport::Concern

  included do
    has_one :review_item, :as => :item, :conditions => { "archived" => false }
    has_many :review_items, :as => :item, :foreign_key => "item_id", :class_name => "ReviewItem"
  end
end
