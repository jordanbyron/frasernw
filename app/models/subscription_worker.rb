require 'debugger'
class SubscriptionWorker < ActiveRecord::Base
  def initialize(subscription)
    @subscription = subscription
  end

  def self.collect_activities(subscription)
    @activities_for_subscription = SubscriptionActivity.collect_activities(subscription.interval_to_datetime,
                                                                           subscription.classification,
                                                                           subscription.divisions,
                                                                           subscription.news_type_masks)
  end

  def self.mail_subscriptions!(subscription)
    @activities_for_subscription = collect_activities(subscription)
    return if @activities_for_subscription.empty?
    mail_by_classification!(@activities_for_subscription, subscription)
  end

  def self.mail_by_classification!(activities_for_subscription, subscription)
    @tracked_objects = to_tracked_objects(activities_for_subscription)

    if subscription.classification == Subscription.resource_update
      SubscriptionMailer.resource_update_email( activities_for_subscription,
                                                self.only_with_specialization(@tracked_objects),
                                                subscription ).deliver!
    else subscription.classification == Subscription.news_update
      SubscriptionMailer.news_update_email( activities_for_subscription,
                                            @tracked_objects,
                                            subscription ).deliver!
    end
  end

  def self.to_tracked_objects(activities_for_subscription)
    activities_for_subscription.map(&:trackable).reject{|i| i != nil}
  end

  def self.only_with_specialization(tracked_objects)
    tracked_objects.reject{|i| i.specializations != s.specializations}
  end
end