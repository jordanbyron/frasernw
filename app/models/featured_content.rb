class FeaturedContent < ActiveRecord::Base
  belongs_to :division
  belongs_to :sc_category
  belongs_to :sc_item
  belongs_to :front
  
  def self.in_divisions(divisions)
    division_ids = divisions.map{ |division| division.id }
    where('"division_id" IN (?)', division_ids)
  end

  MAX_FEATURED_ITEMS = 4
end
