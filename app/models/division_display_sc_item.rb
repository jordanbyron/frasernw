class DivisionDisplayScItem < ActiveRecord::Base
  belongs_to :division
  belongs_to :sc_item

  has_one :featured_content_selection,
    -> (display_item){ where(sc_item_id: display_item.sc_item_id) },
    through: :division,
    source: :featured_contents,
    dependent: :destroy

  include PaperTrailable

end
