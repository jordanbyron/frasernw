class EventMailer < ActionMailer::Base
  include ApplicationHelper
  
  def mail_specialist_clinic_feedback(feedback_item)
    @feedback_item = feedback_item
    item = feedback_item.item
    feedback_provider = feedback_item.user
    owner = item.owner_for_divisions(feedback_provider.divisions)
    mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.name} has had feedback left on it")
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
    if (review_item.whodunnit.present?)
      #if we know who edited this item lets try to get the owner from their division first
      editied_by_user = User.find(review_item.whodunnit)
      divisions = left_by_user.divisions
      owner = item.owner_for_divisions(divisions)
      mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.name} has had been edited by #{editied_by_user.name} and is in the review queue")
    else
      owner = item.owner_for_divisions(item.divisions)
      mail(:to => owner.email, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: #{item.name} has had been edited using the secret edit link and is in the review queue")
    end
  end
  
end
