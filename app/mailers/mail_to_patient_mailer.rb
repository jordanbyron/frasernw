class MailToPatientMailer < ActionMailer::Base
  include ApplicationHelper

  def mail_to_patient(sc_item, user, patient_email)
    @sc_item = sc_item
    @user = user
    @markdown_content =
      if @sc_item.markdown_content.present?
        BlueCloth.new(@sc_item.markdown_content).to_html.html_safe
      end
    mail(
      to: patient_email,
      from: 'noreply@pathwaysbc.ca',
      reply_to: 'noreply@pathwaysbc.ca',
      subject: "#{user.name} has sent you a link to a medical resource"
    )
  end

end
