module SubscriptionsHelper

	def interval_options
		[['Daily'], ['Weekly'], ['Monthly']]
	end

	def news_type_options
	  #NewsItem::TYPE_HASH.map{|key, value| [value]}
	  NewsItem::TYPE_HASH
	end

	def classification_options
	  #Subscription::UPDATE_CLASSIFICATION_HASH.map{|key, value| [key]}
	  Subscription::UPDATE_CLASSIFICATION_HASH
	end
end
