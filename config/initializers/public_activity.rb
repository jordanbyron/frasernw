PublicActivity::Activity.class_eval do
  attr_accessible :update_classification_type,
    :type_mask,
    :type_mask_description,
    :parent_id,
    :parent_type,
    :recipient_id,
    :recipient_type,
    :format_type,
    :format_type_description

  belongs_to :parent, polymorphic: true

  after_create do
    SubscriptionWorker.delay.mail_notifications_for_activity(self.id)
  end
end
