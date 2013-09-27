class EventMailer < ActionMailer::Base
  include ApplicationHelper
  
  def mail_specialist_clinic_feedback(feedback_item)
    @feedback_item = feedback_item
    item = @feedback_item.item
    feedback_provider = feedback_item.user
    owner = item.owner_for_divisions(feedback_provider.divisions)
    mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{feedback_item.item.name} has had feedback left on it")
  end
  
  def mail_content_item_feedback(feedback_item)
    @feedback_item = feedback_item
    item = @feedback_item.item
    owner = item.owner
    mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{feedback_item.item.title} has had feedback left on it")
  end
  
end
