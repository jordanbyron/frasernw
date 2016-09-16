# TODO remove: end_date = DateTime.civil(2016, 8, 29, 7, 0, 0, "-7")

class SubscriptionWorker
  def self.mail_notifications_for_interval(date_interval, end_datetime = DateTime.current)
    User.with_subscriptions.each do |user|
      Subscription::TARGET_CLASSES.map do |klassname, label|
        begin
          subscriptions = user.
            subscriptions_by_interval_and_target(date_interval, klassname)

          items_captured = subscriptions.map do |subscription|
              subscription.items_captured(end_datetime)
            end.
            flatten.
            uniq

          if items_captured.any?
            SubscriptionMailer.send(
              "periodic_#{klassname.tableize.singularize}_notification",
              items_captured,
              user.id,
              date_interval,
              end_datetime
            ).deliver
          end
        rescue => e
          SystemNotifier.error(e)
        end
      end

      true
    end
  end

  def self.mail_notifications_for_item(klass_name, id)
    item = klass_name.constantize.find(id)

    users = User.
      with_subscriptions.
      where("subscriptions.interval = (?)", Subscription::INTERVAL_IMMEDIATELY)

    users.each do |user|
      if user.subscriptions.immediate.any? do |subscription|
        subscription.items_captured.include?(item)
      end

        SubscriptionMailer.send(
          "immediate_#{klass_name.tableize.singularize}_notification",
          item.id,
          user.id
        ).deliver
      end
    end

    true
  end

  def self.mail_availability_notifications
    Specialist.select do |specialist|
      (specialist.status_mask == 6) &&
        (specialist.unavailable_to == Date.current + 1.weeks)
    end.each do |specialist|
      User.select do |user|
        user.admin? && user.divisions == specialist.divisions
      end.each do |user|
        CourtesyMailer.availability_update(
          user.id,
          specialist.id
        ).deliver
      end
    end
  end
end
