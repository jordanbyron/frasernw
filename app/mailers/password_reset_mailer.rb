class PasswordResetMailer < ActionMailer::Base
  default from: "passwordreset@pathwaysbc.ca"
  
  def password_reset_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Pathways: reset your password")
  end
  
end
