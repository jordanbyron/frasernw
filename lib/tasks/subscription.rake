namespace :pathways do
  namespace :subscription do

    task daily: :environment do
      # users.with_subscriptions.each do |user|
          # message_items = []
          # content_items.each do |ci|
          # 
          # (user.subscription && subscription_preferences)

      # end

    end

    task weekly: :environment do
    end

    task monthly: :environment do
    end

    task all: [:monthly, :weekly, :daily] do

    end
  end
end