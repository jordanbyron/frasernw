class MessagesMailer < ActionMailer::Base
  
  default to: 'administration@pathwaysbc.ca', :from => 'noreply@pathwaysbc.ca'
  
  def new_message(message, user)
    @message = message
    
    primary_contacts = user.divisions.map{ |d| d.primary_contacts}.flatten.uniq
    
    if primary_contacts.present? && (primary_contacts.length > 0)
      primary_contacts.each do |primary_contact|
        begin
          mail(:to => primary_contact.email, :subject => "Pathways: #{message.subject}", :reply_to => message.email)
        rescue Exception => e
          mail(:to => 'administration@pathwaysbc.ca', :subject => "Pathways: #{message.subject}", :reply_to => message.email)
        end
      end
    else
      mail(:to => 'administration@pathwaysbc.ca', :subject => "Pathways: #{message.subject}", :reply_to => message.email)
    end
  end
end
