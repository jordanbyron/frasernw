class MailToPatientMailer < ActionMailer::Base
  include ApplicationHelper
  
  def mail_to_patient(sc_item, user, patient_email)
    @sc_item = sc_item
    @user = user
    mail(:to => patient_email, :from => 'noreply@pathwaysbc.ca', :reply_to => 'noreply@pathwaysbc.ca', :subject => "#{user.name} has sent you a link to a medical resource")
  end
  
end
