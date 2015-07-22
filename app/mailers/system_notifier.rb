module SystemNotifier

  # convenience wrappers for #notify
  def self.notice(subject)
    notify(
      tag: :notice,
      subject: subject,
      body: { timestamp: DateTime.now.to_s }
    )
  end

  # #notify wraps whatever system notification system(s) we want to be using
  # TODO: all system notifications, including errors, should come through here
  # takes {tag: <:sym>, subject: <"str">, body: <{}>}
  def self.notify(options)
    SystemMailer.notification(options).deliver
  end
end
