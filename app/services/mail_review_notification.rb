class MailReviewNotification < ServiceObject
  attribute :review_item_id

  def call
    ReviewItemsMailer.user_edited(ReviewItem.find(review_item_id)).deliver
  end
end
