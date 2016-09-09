class SubscriptionWorker
  def self.mail_notifications_for_interval(date_interval)
    User.with_subscriptions.each do |user|
      Subscription::TARGET_TYPES.map do |key, type|
        begin
          subscriptions = user.
            subscriptions_by_interval_and_target(date_interval, type)

          items_captured = subscriptions.map(&:items_captured).flatten.uniq

          if items_captured.any?
            if key == Subscription::RESOURCE_UPDATES
              SubscriptionMailer.periodic_resource_update(
                items_captured,
                user.id,
                date_interval
              ).deliver

            elsif key == Subscription::NEWS_UPDATES
              SubscriptionMailer.periodic_news_update(
                items_captured,
                user.id,
                date_interval
              ).deliver
            end
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
      with_subscriptions.
      where("subscriptions.interval = (?)", Subscription::INTERVAL_IMMEDIATELY)

    users.each do |user|
      if user.subscriptions.immediate.any? do |subscription|
        subscription.items_captured.include?(item)
      end
        if activity.update_classification_type == Subscription.resource_update
          SubscriptionMailer.immediate_resource_update(item.id, user.id).deliver
        elsif activity.update_classification_type == Subscription.news_update
          SubscriptionMailer.immediate_news_update(item.id, user.id).deliver
        end
      end
    end

    true
  end

  def self.mail_availability_notifications
    Specialist.select do |specialist|
      (specialist.status_mask == 6) &&
        (specialist.unavailable_to == Date.current + 1.weeks)
    end.each do |specialist|
      User.select do |user|
        user.admin? && user.divisions == specialist.divisions
      end.each do |user|
        SubscriptionMailer.availability_update(
          user.id,
          specialist.id
        ).deliver
      end
    end
  end
end
