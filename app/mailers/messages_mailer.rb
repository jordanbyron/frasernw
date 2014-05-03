class MessagesMailer < ActionMailer::Base
  
  default to: 'administration@pathwaysbc.ca', :from => 'noreply@pathwaysbc.ca'
  
  def new_message(message, user)
    @message = message
    
    begin
      primary_contact = user.divisions.first.primary_contact.email
    rescue Exception => e
      primary_contact = 'administration@pathwaysbc.ca'
    end
    
    mail(:to => primary_contact, :subject => "Pathways: #{message.subject}", :reply_to => message.email)
  end
end
