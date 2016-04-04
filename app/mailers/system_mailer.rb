class SystemMailer < ActionMailer::Base
  def notification(options)
    @body = options.
      except(:body).
      merge(environment: ENV['APP_NAME']).
      merge(options[:body])

    mail(
      to: Rails.application.config.system_notification_recipients,
      from: "noreply@pathwaysbc.ca",
      subject: "[#{options[:tag]}][#{ENV['APP_NAME']}] #{options[:subject]}",
      delivery_method: :smtp
    )
  end
end
