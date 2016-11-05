namespace :pathways do
  namespace :subscription do

    task daily: :environment do
      puts "Mailing Daily subscriptions..... "
      Subscription::MailIntervalNotifications.call(
        date_interval: Subscription::INTERVAL_DAILY
      )
      puts "Daily subscriptions sent!"
    end

    task weekly: :environment do
      puts "Mailing Weekly subscriptions..... "
      Subscription::MailIntervalNotifications.call(
        date_interval: Subscription::INTERVAL_WEEKLY
      )
      puts "Weekly subscriptions sent!"
    end

    task monthly: :environment do
      puts "Mailing Monthly subscriptions..... "
      Subscription::MailIntervalNotifications.call(
        date_interval: Subscription::INTERVAL_MONTHLY,
      )
      puts "Monthly subscriptions sent!"
    end

    task immediately: :environment do
      puts "Mailing Immediately subscriptions..... "
      Subscription::MailIntervalNotifications.call(
        date_interval: Subscription::INTERVAL_IMMEDIATELY
      )
      puts "Immediate subscriptions sent!"
    end

    task all: [:daily, :weekly, :monthly] do
      puts "All subscriptions sent!"
    end
  end
end
