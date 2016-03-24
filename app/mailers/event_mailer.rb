class EventMailer < ActionMailer::Base
  include ApplicationHelper

  def mail_specialist_clinic_feedback(feedback_item)
    @feedback_item = feedback_item
    item = feedback_item.item
    mail(
      to: item.owners.map{|owner| owner.email},
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: #{item.name} has had feedback left on it"
    )
  end

  def mail_content_item_feedback(feedback_item)
    @feedback_item = feedback_item
    item = feedback_item.item
    owner = item.owner
    mail(
      to: owner.email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: #{item.title} has had feedback left on it"
    )
  end

  def mail_review_queue_entry(review_item)
    @review_item = review_item
    @verb = @review_item.no_updates? ? "confirmed as accurate" : "edited"
    @whodunnit = begin
      if @review_item.secret_edit?
        "using a secret edit link"
      else
        "by #{@review_item.editor.name}"
      end
    end

    item = review_item.item
    mail(
      to: item.owners.map{|owner| owner.email},
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: #{item.name} has had been edited and is in the review queue"
    )
  end

end
