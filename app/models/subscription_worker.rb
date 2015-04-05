#require 'debugger'
class SubscriptionWorker < ActiveRecord::Base

  def self.collect_activities(subscription) # processes one subscription
    SubscriptionActivity.collect_activities(subscription: subscription)
  end

  def self.collect_all_activities_for_subscriptions(subscriptions) # processes multiple subscriptions
    @_activities_for_subscriptions = Array.new
    activities_for_subscription = Array.new
    subscriptions.each{|subscription| @_activities_for_subscriptions  << self.collect_activities(subscription) }
    activities_for_subscription = @_activities_for_subscriptions.flatten.sort{|a,b| b.created_at <=> a.created_at } # return collection of unique activities from subscription
    activities_for_subscription.uniq! # must be on separate line or uniq! returns nil if collection is unique
    return activities_for_subscription
  end

  def self.mail_subscriptions!(subscriptions)
    @activities_for_subscriptions = self.collect_all_activities_for_subscriptions(subscriptions)
    if @activities_for_subscriptions.blank?
      @activities_for_subscriptions = self.collect_activities(subscriptions.first)
    end
    return unless @activities_for_subscriptions.present?
    mail_by_classification!(@activities_for_subscriptions, subscriptions.first)
  end

  def self.mail_by_classification!(activities_for_subscriptions, subscription)
    @tracked_objects = self.to_tracked_objects(activities_for_subscriptions)
    if subscription.classification == Subscription.resource_update
      SubscriptionMailer.delay.resource_update_email( activities_for_subscriptions,
                                                self.only_with_specialization(@tracked_objects, subscription),
                                                subscription.id )
    else subscription.classification == Subscription.news_update
      SubscriptionMailer.delay.news_update_email( activities_for_subscriptions,
                                            @tracked_objects,
                                            subscription.id )
    end
  end
  
  def self.collect_subscriptions_by_activities(activity)
      self.collect_all_activities_for_subscriptions(subscription) & activity
  end

  def self.to_tracked_objects(activities_for_subscriptions)
    activities_for_subscriptions.map(&:trackable).reject{|i| i == nil}
  end

  def self.only_with_specialization(tracked_objects, subscription)
    tracked_objects.reject{|i| i.specializations != subscription.specializations}
  end
end