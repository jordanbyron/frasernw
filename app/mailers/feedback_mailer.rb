class FeedbackMailer < ActionMailer::Base
  include ApplicationHelper

  def targeted(feedback_item)
    @feedback_item = feedback_item
    mail(
      to: feedback_item.owners.map(&:email),
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: #{@feedback_item.target_label} has had feedback left on it"
    )
  end

  def general(feedback_item)
    @feedback_item = feedback_item
    mail(
      to: feedback_item.owners.map(&:email),
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: New 'Contact Us' feedback submitted"
    )
  end
end
