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
        ForUser.call(
          user_id: user.id,
          item_id: id,
          klass_name: klass_name,
          delay: true
        )
      end
    end

    class ForUser < ServiceObject
      attribute :klass_name, String
      attribute :item_id, Integer
      attribute :user_id, Integer

      def call
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

      def item
        @item ||= klass_name.constantize.find(item_id)
      end

      def user
        @user ||= User.find(user_id)
      end
    end
  end
end
