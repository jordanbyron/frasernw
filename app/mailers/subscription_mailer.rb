class SubscriptionMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  # def send_subscription_email(message_items, user, interval, subscription, tracked_activity_objects)
  #   #@subscription = subscription
  #   # @user = user
  #   mail(:to => @subscription.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your WEEKLY/DAILY/MONTHLY Resource Update")
  # end

  def resource_update_email(activities_for_subscription, subscription_id)
    @subscription = Subscription.find(subscription_id)
    @user = @subscription.user
    @interval = @subscription.interval_to_words
    @email = @user.email
    @activities = activities_for_subscription
    mail(:to => @subscription.user.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your #{@interval} Resource Update")
  end

  def news_update_email(activities_for_subscription, subscription_id)
    @subscription = Subscription.find(subscription_id)
    @user = @subscription.user
    @interval = @subscription.interval_to_words
    @email = @user.email
    @activities = activities_for_subscription

    mail(:to => @subscription.user.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your #{@interval} News Update")
  end

  def immediate_resource_update_email(activity_id, user_id)
    @user = User.find_by_id(user_id)
    @activity = SubscriptionActivity.find_by_id(activity_id)
    @interval = Subscription::INTERVAL_HASH[Subscription::INTERVAL_IMMEDIATELY]
    @trackable = @activity.trackable
    @trackable_full_title = @trackable.full_title
    @type_mask_description = @activity.type_mask_description
    @update_classification_type = @activity.update_classification_type
    @parent_type = @activity.parent_type
    @division = Division.find_by_id(@activity.owner_id) if @activity.owner_type == "Division"
    @specializations = @activity.trackable.specializations if @activity.trackable.specializations.present?

    mail(:to => @user.email, :from => 'noreply@pathwaysbc.ca', :subject => "[#{@update_classification_type}] #{@division} just added a #{@type_mask_description.downcase} to #{@parent_type}")

  end

  def immediate_news_update_email(activity_id, user_id)
    @user = User.find_by_id(user_id)
    @activity = SubscriptionActivity.find_by_id(activity_id)
    @interval = Subscription::INTERVAL_HASH[Subscription::INTERVAL_IMMEDIATELY]
    @trackable = @activity.trackable
    @division = Division.find(@activity.owner_id) if @activity.owner_type == "Division"
    @type_mask_description = @activity.type_mask_description
    @update_classification_type = @activity.update_classification_type

    mail(:to => @user.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: A #{@type_mask_description} #{@update_classification_type} was just added to #{@division}")

  end


end
