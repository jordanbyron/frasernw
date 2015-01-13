class SubscriptionWorker

  def initialize(subscription)
    @subscription = subscription
  end

  def process_subscriptions!(subscription)
    @activities_for_subscription =  SubscriptionActivity.collect_activities(subscription.interval_to_datetime, subscription.classification, subscription.divisions, subscription.type_mask)
    send_and_filter_by_subscription_classification(@activities)
  end

  private

  def send_and_filter_by_subscription_classsfication(activities_for_subscription, subscription)
    @tracked_objects = @activities_for_subscription.to_tracked_objects
    if subscription.classification == Subscription.resource_updates
      ResourceUpdatesSubscriptionMailer.deliver(@tracked_objects.only_with_specialization)
    elsif subscription.classification == Subscription.news_updates
      NewsUpdatesSubscriptionMailer.deliver(@tracked_objects)
    end
  end

  def to_tracked_objects
    map(&:trackable).reject{|i| i != nil}
  end

  def only_with_specialization
    reject{|i| i.specializations != s.specializations}
  end

end