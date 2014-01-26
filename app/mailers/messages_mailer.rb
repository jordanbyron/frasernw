class MessagesMailer < ActionMailer::Base
  default to: 'administration@pathwaysbc.ca', :from => 'noreply@pathwaysbc.ca'
  
  def new_message(message)
    @message = message
    mail(:subject => "Pathways: #{message.subject}", :reply_to => message.email)
  end
end
