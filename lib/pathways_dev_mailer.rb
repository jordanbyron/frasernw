class PathwaysDevMailer
  def initialize(params = {})
  end

  def deliver!(mail)
    new_recipients = ENV['SYSTEM_NOTIFICATION_RECIPIENTS']
    new_body = "<p>Original Recipients: #{mail.to}</p><hr><br>#{mail.body}"
    new_subject = "[RedirectedMail][#{ENV['APP_NAME']}] #{mail.subject}"

    mail.to = new_recipients
    mail.body = new_body
    mail.subject = new_subject
    mail.content_type = "text/html"

    smtp_settings = Frasernw::Application.config.action_mailer.smtp_settings

    ActionMailer::Base.delivery_methods[:smtp].new(smtp_settings).deliver!(mail)
  end
end
