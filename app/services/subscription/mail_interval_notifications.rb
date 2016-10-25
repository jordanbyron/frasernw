class Subscription
  class MailIntervalNotifications < ServiceObject
    attribute :date_interval, Integer
    attribute :end_datetime, DateTime, default: DateTime.current

    def call
      User.active.admin_or_super.with_subscriptions.each do |user|
        Subscription::TARGET_CLASSES.keys.each do |klassname|
          ForUserAndKlassname.call(
            user_id: user.id,
            klassname: klassname,
            date_interval: date_interval,
            end_datetime: end_datetime,
            delay: true
          )
        end
      end
    end

    class ForUserAndKlassname < ServiceObject
      attribute :user_id, Integer
      attribute :klassname, String
      attribute :date_interval, Integer
      attribute :end_datetime, DateTime

      def call
        subscriptions = user.
          subscriptions_by_interval_and_target(date_interval, klassname)

        items_captured = subscriptions.map do |subscription|
            subscription.items_captured(end_datetime)
          end.
          flatten.
          uniq

        if items_captured.any?
          SubscriptionMailer.send(
            "periodic_#{klassname.tableize.singularize}_notification",
            items_captured,
            user.id,
            date_interval,
            end_datetime
          ).deliver
        end
      end

      def user
        @user ||= User.find(user_id)
      end
    end
  end
end
