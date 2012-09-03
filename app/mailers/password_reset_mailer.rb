class PasswordResetMailer < ActionMailer::Base
  
  def password_reset_instructions(user)
    @user = user
    mail(:to => user.email, :from => 'passwordreset@pathwaysbc.ca', :reply_to => 'passwordreset@pathwaysbc.ca', :subject => "Pathways: reset your password")
  end
  
end
