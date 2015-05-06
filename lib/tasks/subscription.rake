namespace :pathways do
  namespace :subscription do
  include Rails.application.routes.url_helpers

    task daily: :environment do
      puts "Mailing Daily subscriptions..... "
      SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_DAILY)
      puts "Daily subscriptions sent!"
    end

    task weekly: :environment do
      puts "Mailing Weekly subscriptions..... "
      SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_WEEKLY)
      puts "Weekly subscriptions sent!"
    end

    task monthly: :environment do
      puts "Mailing Monthly subscriptions..... "
      SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)
      puts "Monthly subscriptions sent!"
    end

    task immediately: :environment do
      puts "Mailing Immediately subscriptions..... "
      SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_IMMEDIATE)
      puts "Immediate subscriptions sent!"
    end

    task all: [:daily, :weekly, :monthly] do
      puts "All subscriptions sent!"
    end
  end
end