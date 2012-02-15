class SpecialistMailer < ActionMailer::Base
  default from: ENV['SMTP_USER']
  
  def invite_specialist(specialist)
    @specialist = specialist
    mail(:to => specialist.contact_email, :subject => "You've been invited to edit the Pathways directory entry for #{specialist.name}")
  end
  
  def updated_by_self(specialist)
    @specialist = specialist
    mail(:to => all_admins, :subject => "[Pathways] #{specialist.name} has been edited by self")
  end
  
  private
  def all_admins
    admin_emails = []
    admins = User.find(:all).where('role = ?','admin')
    admins.each do |a|
      admin_emails << admin.email
    end
    admin_emails
  end
  
end
