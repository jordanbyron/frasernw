module FeedbackHelper
  def respond_link(feedback)
    if feedback.submitter_email.nil? || feedback.submitter_email == ""
      "unavailable"
    else
      mail_to feedback_item.submitter_email,
        feedback_item.submitter_email,
        subject: "Your Pathways Feedback",
        body: "#{feedback_item.feedback} \n\n Pathways: http://www.pathwaysbc.ca"
    end
  end
end
