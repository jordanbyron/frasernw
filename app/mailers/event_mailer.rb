class EventMailer < ActionMailer::Base
  include ApplicationHelper
  
  def mail_specialist_clinic_feedback(feedback_item)
    @feedback_item = feedback_item
    item = feedback_item.item
    mail(:to => item.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.name} has had feedback left on it")
  end
  
  def mail_content_item_feedback(feedback_item)
    @feedback_item = feedback_item
    item = feedback_item.item
    owner = item.owner
    mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.title} has had feedback left on it")
  end
  
  def mail_review_queue_entry(review_item)
    @review_item = review_item
    item = review_item.item
    mail(:to => item.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.name} has had been edited using the secret edit link and is in the review queue")
  end
  
end
