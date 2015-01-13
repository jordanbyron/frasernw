class NewsUpdatesSubscriptionMailer < ActionMailer::Base
  include Resque::Mailer
  default from: "noreply@pathwaysbc.ca"

  def send_subscription_email(activities_for_subscription, tracked_activity_objects, subscription)

    item = subscription
    @user = subscription.user
    @interval = @subscription.interval_to_words
    @email = @user.email
    @tracked_activity_objects = tracked_activity_objects
    @activities_for_subscription = activities_for_subscription

    mail(:to => item.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your #{@interval} News Update")

  end

end