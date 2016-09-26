class Subscription
  class MailIntervalNotifications < ServiceObject
    attribute :date_interval, Integer
    attribute :end_datetime, DateTime, default: DateTime.current

    def call
      User.active.admin_or_super.with_subscriptions.each do |user|
        Subscription::TARGET_CLASSES.map do |klassname, label|
          begin
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
          rescue => e
            SystemNotifier.error(e)
          end
        end

        true
      end
    end
  end
end
