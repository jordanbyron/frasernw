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

  def self.javascript_error(e, options = {})
    notify(
      tag: "Exception - Client-side",
      subject: e[:message],
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {
        name: e[:name],
        message: e[:message],
        file: e[:file],
        line: e[:line],
        column: e[:column],
        url: e[:url],
        errorStack: e[:errorStack]
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
    SystemMailer.notification(options).deliver
  end
end
