class SubscriptionMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  def periodic_resource_update(activities, user_id, interval_key)
    @user = User.find(user_id)
    @interval = Subscription::INTERVAL_LABELS[interval_key]
    @interval_period = Subscription.interval_period(interval_key)
    @activities = activities

    @divisions_activities = @activities.
      group_by{|activity| activity.trackable.division }.
      map do |division, activities|
        {
          division: division,
          activities: activities,
          share_with_divisions: share_with_divisions(activities, @user)
        }
      end

    @share_all_with_divisions = share_with_divisions(@activities, @user)

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: "Pathways: New Resources were added #{@interval_period} to Pathways [Resource Update]"
    )
  end

  def periodic_news_update(activities, user_id, interval_key)
    @user = User.find(user_id)
    @interval = Subscription::INTERVAL_LABELS[interval_key]
    @interval_period = Subscription.interval_period(interval_key)
    @activities = activities

    mail(
      to: @user.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: News Items added to Pathways #{@interval_period} [News Update]"
    )
  end

  def immediate_resource_update(activity_id, user_id)
    @user = User.find_by_id(user_id)
    @activity = SubscriptionActivity.find_by_id(activity_id)
    @interval = Subscription::INTERVAL_LABELS[Subscription::INTERVAL_IMMEDIATELY]
    @trackable = @activity.trackable
    @trackable_full_title = @trackable.full_title
    @type_mask_description_formatted = @activity.type_mask_description_formatted
    @update_classification_type = @activity.update_classification_type
    @parent_type = @activity.parent_type
    @division = Division.find_by_id(@activity.owner_id) if @activity.owner_type == "Division"
    @specializations = @activity.trackable.specializations if @activity.trackable.specializations.present?

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: "Pathways: #{@division} just added #{@type_mask_description_formatted} to #{@parent_type} [#{@update_classification_type.singularize}] "
    )
  end

  def immediate_news_update(activity_id, user_id)
    @user = User.find_by_id(user_id)
    @activity = SubscriptionActivity.find_by_id(activity_id)
    @interval = Subscription::INTERVAL_LABELS[Subscription::INTERVAL_IMMEDIATELY]
    @trackable = @activity.trackable
    @division = Division.find(@activity.owner_id) if @activity.owner_type == "Division"
    @type_mask_description_formatted = @activity.type_mask_description_formatted
    @update_classification_type = @activity.update_classification_type

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: "Pathways: #{@type_mask_description_formatted} was just added to #{@division} [#{@update_classification_type.singularize}]"
    )
  end

  private

  def share_with_divisions(activities, user)
    user.divisions.inject({}) do |memo, division|
      eligible_resources = activities.
        map(&:trackable).
        select{ |resource| resource.borrowable_by_divisions.include?(division) }

      memo.merge({
        division => eligible_resources.map(&:id)
      })
    end.keep_if{ |k, v| v.any? }
  end
end
