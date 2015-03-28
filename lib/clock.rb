require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

every(1.minutes, "pathways:subscription:monthly") do
    'rake pathways:subscription:monthly'
    'rake jobs:workoff'
    # Frasernw::Application
    # Rake::Task['pathways:subscription:monthly'].invoke
    # Rake::Task['jobs:work'].invoke
  end

  # every(1.minutes, "pathways:subscription:immediate") do
  #   # SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_IMMEDIATELY)
  #   execute_rake("subscription.rake","pathways:subscription:monthly")
  #   execute_rake("subscription.rake","jobs:work")
  # end

  # every(1.minutes, 'Queueing immediate interval job') do
  #   # SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_IMMEDIATELY)
  #   execute_rake("subscription.rake","pathways:subscription:monthly")
  #   execute_rake("subscription.rake","jobs:work")
  # end

  # every(20.seconds, 'Queueing daily scheduled job') do
  #   Dir.chdir '/lib/tasks/subscription.rake' #rails3.2 upgrade note: change to Rails.root
  #   `rake pathways:subscription:daily`
  #   'rake jobs:workoff'
  # end



  # every(1.day, 'Queueing daily scheduled job', :at => '14:30', :tz => 'UTC') do
  #   Dir.chdir '#{Rails.root}/lib/tasks/subscription/'
  #   `rake pathways:subscription:daily`
  #   'rake jobs:workoff'
  # end



  # every(1.weeks, 'Queueing weekly scheduled job', :at => 'Monday 14:30',  :tz => 'UTC') do

  #   Delayed::Job.enqueue SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_WEEKLY)

  # end


  # # Run on every first day of month at 2:00pm UTC, 6:00 am PST
  # Clockwork.every(1.day, 'Queueing Monthly scheduled job', :at => '14:00', :tz => 'UTC', :if => lambda { |t| t.day == 1 }) do

  #   Delayed::Job.enqueue SubscriptionUserWorker.mail_subscriptions_by_date!(Subscription::INTERVAL_MONTHLY)

  # end

