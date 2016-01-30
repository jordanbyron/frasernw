module SystemNotifier
  # convenience wrappers for #notify


  def self.info(subject)
    notify(
      tag: :info,
      subject: subject,
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {}
    )
  end

  def self.error(e, options = {})
    notify(
      tag: :error,
      subject: e.message,
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {
        annotation: (options[:annotation] || "None"),
        backtrace: e.backtrace
      }
    )
  end

  # #notify wraps whatever system notification system(s) we want to be using
  # TODO: all system notifications, including errors, should come through here
  # takes {tag: <:sym>, subject: <"str">, body: <{}>}
  def self.notify(options)
    SystemMailer.notification(options).deliver
  end
end
