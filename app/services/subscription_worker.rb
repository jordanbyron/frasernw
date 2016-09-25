class SubscriptionWorker
  def self.mail_notifications_for_interval(date_interval, end_datetime = DateTime.current)
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

  def self.mail_notifications_for_item(klass_name, id)
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
