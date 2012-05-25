class PasswordResetMailer < ActionMailer::Base
  default from: ENV['SMTP_USER']
  
  def password_reset_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Pathways: reset your password")
  end
  
end
