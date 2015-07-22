class SystemMailer < ActionMailer::Base
  def notification(options)
    @body = options[:body]

    mail(
      to: Rails.application.config.system_notification_recipients,
      from: "noreply@pathwaysbc.ca",
      subject: "[pathways_system_#{options[:tag]}] [#{ENV['APP_NAME']}] #{options[:subject]}"
    )
  end
end
