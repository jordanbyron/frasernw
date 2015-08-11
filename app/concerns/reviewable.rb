module Reviewable
  extend ActiveSupport::Concern

  included do
    has_one :review_item, :as => :item, :conditions => { "archived" => false }
    has_many :review_items, :as => :item, :foreign_key => "item_id", :class_name => "ReviewItem"
  end

  def full_notes_history
    return @full_notes_history if defined? @full_notes_history

    unsorted = (notes_history + review_items_notes_history)
    @full_notes_history ||= unsorted.sort_by do |node|
      node.datetime
    end
  end

  def review_items_notes_history
    review_items.map do |review_item|
      review_item.notes_history
    end.flatten
  end
end
