require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork
  error_handler do |error|
    SystemNotifier.error(error)
  end

  if ENV['APP_NAME'] == "pathwaysbc" # production
    every(
      1.weeks,
      'bundle exec rake deploy:backup',
      at: 'Sunday 08:05',
      tz: 'UTC'
    ) { `bundle exec rake deploy:backup` }

    every(
      1.weeks,
      'bundle exec rake pathways:delete_old_sessions',
      at: 'Sunday 08:10',
      tz: 'UTC'
    ) { `bundle exec rake pathways:delete_old_sessions` }

    every(
      1.weeks,
      'bundle exec rake deploy:backup',
      at: 'Sunday 08:15',
      tz: 'UTC'
    ) { `bundle exec rake deploy:backup` }

    every(
      1.weeks,
      'bundle exec rake pathways:remove_deceased_specialist_records',
      at: 'Sunday 08:20',
      tz: 'UTC'
    ) { `bundle exec rake pathways:remove_deceased_specialist_records` }

  end

  every(
    1.day,
    'heroku restart',
    at: '13:00',
    tz: 'UTC'
  ){ `heroku restart` }

  every(
    1.day,
    'bundle exec rake pathways:visit_every_page:specializations',
    at: '12:30',
    tz: 'UTC'
  ) { `bundle exec rake pathways:visit_every_page:specializations` }

  # Mails notifications DAILY at 2:30pm UTC (14:30), 6:30 am PST
  every(
    1.day,
    'Mail Availability Notifications job',
    at: '14:30',
    tz: 'UTC'
  ) do
    MailAvailabilityNotifications.call(delay: true)
  end

  # Mails subscriptions DAILY at 2:30pm UTC (14:30), 6:30 am PST
  every(
    1.day,
    'Mail Daily Subscriptions job',
    at: '14:30',
    tz: 'UTC'
  ) do
    Subscription::MailIntervalNotifications.call(
      date_interval: Subscription::INTERVAL_DAILY,
      delay: true
    )
  end

  # Mail subscriptions WEEKLY on Mondays at 2:00pm UTC (14:00), 6:00 am PST
  every(
    1.weeks,
    'Mail Weekly Subscriptions job',
    at: 'Monday 14:00',
    tz: 'UTC'
  ) do
    Subscription::MailIntervalNotifications.call(
      date_interval: Subscription::INTERVAL_WEEKLY,
      delay: true
    )
  end

  # Mail subscriptions MONTHLY on 1st day of month at 4:00pm UTC (16:00), 8:00 am PST
  every(
    1.day,
    'Mail out Monthly Subscriptions job',
    at: '16:00',
    tz: 'UTC',
    if: lambda { |t| t.day == 1 }
  ) do
    Subscription::MailIntervalNotifications.call(
      date_interval: Subscription::INTERVAL_MONTHLY,
      delay: true
    )
  end

  every(
    1.day,
    'Mail out Monthly Subscriptions job',
    at: '16:00',
    tz: 'UTC',
    if: lambda { |t| t.day == 1 }
  ) do
    Subscription::MailIntervalNotifications.call(
      date_interval: Subscription::INTERVAL_MONTHLY,
      delay: true
    )
  end

  every(
    1.day,
    'Update specialist availability statuses',
    at: '3:00',
    tz: 'Pacific Time (US & Canada)'
  ) do
    UpdateSpecialistAvailability.call(delay: true)
  end

  every(
    1.day,
    'Update specialist availability statuses',
    at: '3:00',
    tz: 'Pacific Time (US & Canada)'
  ) do
    UpdateClinicClosure.call(delay: true)
  end
end
