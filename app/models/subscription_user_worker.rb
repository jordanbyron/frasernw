class SubscriptionUserWorker < ActiveRecord::Base
  ## Email flow 1:
  # Deliver Immediate Emails to User based if classification matches:
  def self.mail_subscriptions_by_date!(date_interval) #date_interval is integer value in Subscription
    ActiveRecord::Base.transaction do
      User.with_subscriptions.each do |user|
        next unless user.subscriptions.present?
        Subscription::UPDATE_CLASSIFICATION_HASH.map do |key, value| # send merged emails by classification & date
          @subscriptions = user.subscriptions_by_interval_and_classification(date_interval, value)
          next unless @subscriptions.present? # Do not mail unless user has Subscription for date_interval & classification
          SubscriptionWorker.mail_subscriptions!(@subscriptions)
        end
      end
    end
  end


  ## Email flow 2:
  # Deliver Immediate Emails to all users subscribed to a given activity
  def self.mail_subscriptions_by_activity!(activity_id) # task for mailing IMMEDIATE notifications of single activities
    @activity = SubscriptionActivity.find(activity_id)
    ActiveRecord::Base.transaction do
      User.with_subscriptions.each do |user|
        next unless user.subscriptions.all_immediately.present?
        Subscription::UPDATE_CLASSIFICATION_HASH.map do |key, value| # send merged emails by classification & date
          @subscriptions = user.subscriptions_with_activity_in_interval_in_class(@activity, Subscription::INTERVAL_IMMEDIATELY, value)
          next unless @subscriptions.present? # Do not mail unless user has Immediate Subscription for @activity
          if @activity.update_classification_type == Subscription.resource_update
            @specializations = @subscriptions.map(&:specializations).map{|specialization| specialization & @activity.trackable.specializations}.flatten.uniq
            next unless @specializations.present? # Do not mail unless user has Immediate Subscription for @activity
            SubscriptionMailer.immediate_resource_update_email(@activity.id, user.id).deliver
          end
          SubscriptionMailer.immediate_news_update_email(@activity.id, user.id).deliver if @activity.update_classification_type == Subscription.news_update
        end
      end
    end
  end

end