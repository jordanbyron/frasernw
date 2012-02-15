class UserMailer < ActionMailer::Base
  default from: "frasernw@gmail.com", bcc: "warneboldt@gmail.com"
  
  def welcome_admin(user)
    @user = user
    mail(:to => user.email, :subject => "Pathways: you now have admin rights at mdpathwaysbc.com")
  end
  
end
