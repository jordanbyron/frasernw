require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

  # You can trigger rake tasks like this:
  every(1.minutes, 'bundle exec rake jobs:workoff') {
    `bundle exec rake jobs:workoff`
  }

  # Temporary Test
  Clockwork.every(1.day, 'Mail out TEST Monthly Subscriptions job', :at => 'Monday 07:00', :tz => 'UTC', :if => lambda { |t| t.day == 30 }) do
   SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)
  end

  # Daily
  # Mails subscriptions 1st day of month at 2:30pm UTC (14:30), 6:30 am PST
  every(1.day, 'Mail Daily Subscriptions job', :at => '14:30',  :tz => 'UTC') do
    SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_DAILY)
  end


  # WEEKLY
  # Mails subscriptions 1st day of month at 2:00pm UTC (14:00), 6:00 am PST
  every(1.weeks, 'Mail Weekly Subscriptions job', :at => 'Monday 14:00',  :tz => 'UTC') do
    SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_WEEKLY)
  end


  # MONTHLY
  # Mail Monthly subscriptions on every 1st day of month at 4:00pm UTC (16:00), 8:00 am PST
  Clockwork.every(1.day, 'Mail out Monthly Subscriptions job', :at => '16:00', :tz => 'UTC', :if => lambda { |t| t.day == 1 }) do
   SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)
  end