class PasswordResetMailer < ActionMailer::Base
  
  def password_reset_instructions(user)
    @user = user
    mail(:to => user.email, :from => 'noreply@pathwaysbc.ca', :reply_to => 'noreply@pathwaysbc.ca', :subject => "Pathways: reset your password")
  end
  
end
