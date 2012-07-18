class FeaturedContent < ActiveRecord::Base
  belongs_to :sc_category
  belongs_to :sc_item
  belongs_to :front
end
