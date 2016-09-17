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
        user_id: e[:user_id],
        user_mask: e[:user_mask],
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

  # TODO: all system notifications, including errors, should come through here

  # takes {tag: <:sym>, subject: <"str">, body: <{}>}
  def self.notify(options)
    SystemMailer.notification(options).deliver
  end
end
