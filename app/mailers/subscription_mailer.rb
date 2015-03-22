class SubscriptionMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  # def send_subscription_email(message_items, user, interval, subscription, tracked_activity_objects)
  #   #@subscription = subscription
  #   # @user = user
  #   mail(:to => @subscription.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your WEEKLY/DAILY/MONTHLY Resource Update")
  # end

  def resource_update_email(activities_for_subscription, tracked_activity_objects, subscription)
    @subscription = subscription
    @user = @subscription.user
    @interval = @subscription.interval_to_words
    @email = @user.email
    @tracked_activity_objects = tracked_activity_objects
    @activities = activities_for_subscription

    mail(:to => @subscription.user.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your #{@interval} Resource Update")
  end

  def news_update_email(activities_for_subscription, tracked_activity_objects, subscription)
    @subscription = subscription
    @user = @subscription.user
    @interval = @subscription.interval_to_words
    @email = @user.email
    @tracked_activity_objects = tracked_activity_objects
    @activities = activities_for_subscription

    mail(:to => @subscription.user.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your #{@interval} News Update")
  end

end
