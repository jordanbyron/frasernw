module SubscriptionsHelper

	def interval_options
		[['Daily'], ['Weekly'], ['Monthly']]
	end

	def news_type_options
		[ [NewsItem::TYPE_HASH[1]], [NewsItem::TYPE_HASH[2]], [NewsItem::TYPE_HASH[3]], [NewsItem::TYPE_HASH[4]], [NewsItem::TYPE_HASH[5]] ]
	end

end
