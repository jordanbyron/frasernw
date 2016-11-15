class FeaturedContent < ActiveRecord::Base
  attr_accessible :division_id,
    :sc_category_id,
    :sc_item_id

  belongs_to :division
  belongs_to :sc_category
  belongs_to :sc_item

  scope :in_category, -> (category) { where(sc_category_id: category.id) }

  after_commit :flush_cache
  after_touch :flush_cache

  def self.in_divisions(divisions)
    where('"division_id" IN (?)', divisions.map(&:id))
  end

  MAX_FEATURED_ITEMS = 4

  private

  def flush_cache
    ExpireFragment.call "featured_content_#{self.division_id}"
  end
end
