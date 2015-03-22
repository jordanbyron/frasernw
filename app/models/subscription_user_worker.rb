class SubscriptionUserWorker < ActiveRecord::Base

  def self.mail_subscriptions_by_date!(date_interval) #date_interval is integer value in Subscription
    User.with_subscriptions.each do |user|
      next unless user.subscriptions.present?
      Subscription::UPDATE_CLASSIFICATION_HASH.map do |key, value| # send merged emails by classification & date
        subscriptions = (user.subscriptions_by_classification(value) & user.subscriptions_by_date_interval(date_interval))
        next unless subscriptions.present?
        SubscriptionWorker.mail_subscriptions!(subscriptions)
      end
    end
  end
end