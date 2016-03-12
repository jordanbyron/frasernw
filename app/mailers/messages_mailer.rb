class MessagesMailer < ActionMailer::Base
  include ApplicationHelper

  def new_message(message, user)
    @message = message

    primary_contacts = user.divisions.map(&:primary_contacts).flatten.uniq

    if primary_contacts.any?
      mail(
        to: primary_contacts.map(&:email),
        subject: "Pathways: #{message.subject}",
        reply_to: message.email
      )
    else
      mail(
        to: primary_support_emails,
        subject: "Pathways: #{message.subject}",
        reply_to: message.email
      )
    end
  end
end
