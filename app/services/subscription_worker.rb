class SubscriptionWorker
  def self.mail_notifications_for_interval(date_interval)
    User.with_subscriptions.each do |user|
      Subscription::TARGET_TYPES.map do |key, type|
        begin
          subscriptions = user.
            subscriptions_by_interval_and_target(date_interval, type)

          activities = subscriptions.map(&:activities).flatten.uniq

          if activities.any?
            if key == Subscription::RESOURCE_UPDATES
              SubscriptionMailer.periodic_resource_update(
                activities,
                user.id,
                date_interval
              )

            elsif key == Subscription::NEWS_UPDATES
              SubscriptionMailer.periodic_news_update(
                activities,
                user.id,
                date_interval
              )
            end
          end
        rescue => e
          SystemNotifier.error(e)
        end
      end
    end
  end

  def self.mail_notifications_for_activity(activity_id)
    activity = SubscriptionActivity.find(activity_id)

    users = User.
      with_subscriptions.
      where("subscriptions.interval = (?)", Subscription::INTERVAL_IMMEDIATELY)

    users.each do |user|
      if user.subscriptions.immediate.any?{|subscription| subscription.activities.include?(activity) }
        if activity.update_classification_type == Subscription.resource_update
          SubscriptionMailer.immediate_resource_update(activity.id, user.id).deliver
        elsif activity.update_classification_type == Subscription.news_update
          SubscriptionMailer.immediate_news_update(activity.id, user.id).deliver
        end
      end
    end
  end
end
