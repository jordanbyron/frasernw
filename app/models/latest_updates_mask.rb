class LatestUpdatesMask < ActiveRecord::Base
  belongs_to :item, polymorphic: true

  attr_accessible :event_code,
    :division_id,
    :item_type,
    :item_id,
    :date

  EVENTS = {
    0 => :moved_away,
    1 => :retired,
    2 => :retiring,
    3 => :opened_recently
  }

  def item_name
    item.name
  end
end
