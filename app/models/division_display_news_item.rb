class DivisionDisplayNewsItem < ActiveRecord::Base
  belongs_to :division
  belongs_to :news_item

  attr_accessible :division_id, :news_item_id


end
