module MailSubscriptionNotifications
  class Subscribed < ServiceObject
    attribute :subscription_id

    def call
      IssuesMailer.subscribed(IssueSubscription.find(subscription_id)).deliver
    end

  end

  class Completed < ServiceObject
    attribute :subscription_id

    def call
      IssuesMailer.completed(IssueSubscription.find(subscription_id)).deliver
    end

  end
end
