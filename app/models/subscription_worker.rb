class SubscriptionWorker < Subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def self.process_subscriptions!(subscription)
    @activities_for_subscription =  SubscriptionActivity.collect_activities(subscription.interval_to_datetime, subscription.classification, subscription.divisions, subscription.news_type_masks)
    self.send_and_filter_by_subscription_classification(@activities_for_subscription, subscription)
  end


  def self.send_and_filter_by_subscription_classification(activities_for_subscription, subscription)
    @activities_for_subscription = activities_for_subscription
    @tracked_objects = self.to_tracked_objects(@activities_for_subscription)
    if subscription.classification == Subscription.resource_update
      SubscriptionMailer.send_resource_update_subscription_email(activities_for_subscription, self.only_with_specialization(@tracked_objects), subscription).deliver!
    elsif subscription.classification == Subscription.news_update
      SubscriptionMailer.send_news_update_subscription_email(activities_for_subscription, @tracked_objects, subscription).deliver!
    end
  end

  def self.to_tracked_objects(activities)
    activities.map(&:trackable).reject{|i| i != nil}
  end

  def self.only_with_specialization(tracked_objects)
    tracked_objects.reject{|i| i.specializations != s.specializations}
  end
  private

end