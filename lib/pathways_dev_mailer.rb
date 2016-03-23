class PathwaysDevMailer < Mail::SMTP
  def deliver!(mail)
    new_recipients = ENV['SYSTEM_NOTIFICATION_RECIPIENTS']
    new_body = "<p>Original Recipients: #{mail.to}</p><hr>"
    new_subject = "[Dev Mail][#{ENV['APP_NAME']}] #{mail.subject}"

    mail.to = new_recipients
    mail.body = new_body
    mail.subject = new_subject

    super(mail)
  end
end
