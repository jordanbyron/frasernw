class SubscriptionUserWorker < ActiveRecord::Base

  def self.mail_subscriptions_by_date!(date_interval) #date_interval is integer value in Subscription
    User.with_subscriptions.each do |user|
      next unless user.subscriptions.present?
      user.subscriptions_by_date_interval(date_interval).each do |subscription|
        SubscriptionWorker.process_subscriptions!(subscription)
      end
    end
  end
end