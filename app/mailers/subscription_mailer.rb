class SubscriptionMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  def periodic_sc_item_notification(sc_items, user_id, interval_key, end_datetime)
    @user = User.find(user_id)
    @interval = Subscription::INTERVAL_LABELS[interval_key]
    @interval_period = Subscription.interval_period(interval_key)
    @end_datetime = end_datetime

    @divisions_sc_items = sc_items.
      group_by{|sc_item| sc_item.division }.
      map do |division, sc_items|
        {
          division: division,
          sc_items: sc_items.sort_by(&:created_at).reverse,
          share_with_divisions: share_with_divisions(sc_items, @user)
        }
      end

    @share_all_with_divisions = share_with_divisions(sc_items, @user)

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: ("Pathways: Content Items were added #{@interval_period} to " +
        "Pathways [Content Item Update]")
    )
  end

  def periodic_news_item_notification(news_items, user_id, interval_key, end_datetime)
    @user = User.find(user_id)
    @interval = Subscription::INTERVAL_LABELS[interval_key]
    @interval_period = Subscription.interval_period(interval_key)
    @news_items = news_items.sort_by(&:created_at).reverse
    @end_datetime = end_datetime

    mail(
      to: @user.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: News Items added to Pathways #{@interval_period} "\
        "[News Update]"
    )
  end

  def immediate_sc_item_notification(sc_item_id, user_id)
    @user = User.find_by_id(user_id)
    @interval = Subscription::INTERVAL_LABELS[Subscription::INTERVAL_IMMEDIATELY]
    @sc_item = ScItem.find(sc_item_id)

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: ("Pathways: #{@sc_item.division} just added " +
        "a #{@sc_item.type_label} to #{@sc_item.root_category.name} " +
        "[Content Item Update] ")
    )
  end

  def immediate_news_item_notification(news_item_id, user_id)
    @user = User.find_by_id(user_id)
    @news_item = NewsItem.find_by_id(news_item_id)
    @interval = Subscription::INTERVAL_LABELS[Subscription::INTERVAL_IMMEDIATELY]

    mail(
      to: @user.email,
      from: 'Pathways <noreply@pathwaysbc.ca>',
      subject: ("Pathways: #{@news_item.type} was just added to " +
        "#{@news_item.owner_division} [News Update]")
    )
  end

  private

  def share_with_divisions(sc_items, user)
    user.divisions.inject({}) do |memo, division|
      eligible_resources = sc_items.
        select{ |sc_item| sc_item.borrowable_by_divisions.include?(division) }

      memo.merge({
        division => eligible_resources.map(&:id)
      })
    end.keep_if{ |k, v| v.any? }
  end
end
