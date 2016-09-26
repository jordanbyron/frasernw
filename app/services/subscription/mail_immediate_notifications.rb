class Subscription
  class MailImmediateNotifications < ServiceObject
    attribute :klass_name, String
    attribute :id, Integer

    def call
      item = klass_name.constantize.find(id)

      users = User.
        active.
        admin_or_super.
        with_subscriptions.
        where("subscriptions.interval = (?)", Subscription::INTERVAL_IMMEDIATELY)

      users.each do |user|
        if user.subscriptions.immediate.any? do |subscription|
          subscription.items_captured.include?(item)
        end

          SubscriptionMailer.send(
            "immediate_#{klass_name.tableize.singularize}_notification",
            item.id,
            user.id
          ).deliver
        end
      end

      true
    end
  end
end
