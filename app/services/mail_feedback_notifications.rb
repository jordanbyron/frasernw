class MailFeedbackNotifications < ServiceObject
  attribute :feedback_item_id, Integer

  def call
    feedback_item = FeedbackItem.find(feedback_item_id)

    if feedback_item.contact_us?
      FeedbackMailer.general(feedback_item).deliver
    else
      FeedbackMailer.targeted(feedback_item).deliver
    end
  end
end
