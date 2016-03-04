class DemoableNewsItem < ActiveRecord::Base
  attr_accessible :news_item_id

  belongs_to :news_item

end
