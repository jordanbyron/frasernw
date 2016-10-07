require 'active_support/inflector'

module SystemNotifier
  def self.info(subject)
    notify(
      tag: "Info",
      subject: subject,
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {}
    )
  end

  def self.error(e, options = {})
    notify(
      tag: "Exception",
      subject: e.message,
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {
        annotation: (options[:annotation] || "None"),
        backtrace: e.backtrace
      }
    )
  end

  def self.migrations_pending(number)
    notify(
      tag: "Deploy - Migrations pending",
      subject: "There #{'is'.pluralize(number)} #{number.to_s} pending "\
        "#{'migration'.pluralize(number)}.",
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {}
    )
  end

  def self.catch_error(error_klass, &block)
    begin
      block.call
    rescue error_klass => e
      SystemNotifier.error(e)
    end
  end

  private

  # takes {tag: <:sym>, subject: <"str">, body: <{}>}
  def self.notify(options)
    begin
      SystemMailer.notification(options).deliver
    rescue Net::SMTPAuthenticationError, EOFError, Net::SMTPUnknownError
      NotifyInBackground.call(options: options, delay: true)
    end
  end
end
