require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

  # Delete sessions older than every week
  if ENV['APP_NAME'] == "pathwaysbctest" # production
    # every(1.day, 'bundle exec rake backup_db', :at => '08:00',  :tz => 'UTC') {
    #   `bundle exec rake backup_db`
    # }

    every(1.weeks, 'bundle exec rake pathways:delete_old_sessions', :at => 'Sunday 08:10',  :tz => 'UTC') {
      `bundle exec rake pathways:delete_old_sessions`
    }

    # every(1.weeks, 'bundle exec rake backup_db', :at => 'Sunday 08:15',  :tz => 'UTC') {
    #   `bundle exec rake backup_db`
    # }
  end

  every(1.day, 'heroku restart', :at => '13:00',  :tz => 'UTC') {
    `heroku restart`
  }

  every(1.day, 'bundle exec rake pathways:visit_every_page:specializations', :at => '12:30',  :tz => 'UTC') {
    `bundle exec rake pathways:visit_every_page:specializations`
  }

  # Used for testing:
  # Clockwork.every(1.day, 'Mail out TEST Monthly Subscriptions job', :at => 'Monday 00:45', :tz => 'UTC', :if => lambda { |t| t.day == 6 }) do
  #  SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)
  # end

  # Mails subscriptions DAILY at 2:30pm UTC (14:30), 6:30 am PST
  every(1.day, 'Mail Daily Subscriptions job', :at => '14:30',  :tz => 'UTC') do
    SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_DAILY)
  end


  # Mail subscriptions WEEKLY on Mondays at 2:00pm UTC (14:00), 6:00 am PST
  every(1.weeks, 'Mail Weekly Subscriptions job', :at => 'Monday 14:00',  :tz => 'UTC') do
    SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_WEEKLY)
  end


  # Mail subscriptions MONTHLY on 1st day of month at 4:00pm UTC (16:00), 8:00 am PST
  Clockwork.every(1.day, 'Mail out Monthly Subscriptions job', :at => '16:00', :tz => 'UTC', :if => lambda { |t| t.day == 1 }) do
   SubscriptionUserWorker.delay.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)
  end