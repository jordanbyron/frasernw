class IssuesMailer < ActionMailer::Base
  include ApplicationHelper

  def users_subscribed(subscription)
    @subscription = subscription

    mail(
      to: @subscription.subscriber.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "[Pathways] Subscribed to '#{issue_label(@subscription.issue)}'"
    )
  end

  def thread_subscribed(issue)
    @issue = issue

    mail(
      to: @issue.subscribed_thread_participants,
      from: 'noreply@pathwaysbc.ca',
      subject: @issue.subscribed_thread_subject
    )
  end

  def thread_completed(issue)
    @issue = issue

    mail(
      to: @issue.subscribed_thread_participants,
      from: 'noreply@pathwaysbc.ca',
      subject: @issue.subscribed_thread_subject
    )
  end

  def users_completed(subscription)
    @subscription = subscription

    mail(
      to: @subscription.subscriber.email,
      from: 'noreply@pathwaysbc.ca',
      subject: ("[Pathways] '#{issue_label(@subscription.issue)}' " +
        "has been marked 'Completed'")
    )
  end

  private

  def issue_label(issue)
    if @subscription.issue.title.present?
      @subscription.issue.title
    else
      @subscription.issue.description.truncate(40)
    end
  end
end
