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

  def self.javascript_error(error_data, options = {})
    notify(
      tag: "Exception - Client-side",
      subject: error_data[:message],
      timestamp: DateTime.now.to_s(:long_ordinal),
      body: {
        userId: error_data[:userId],
        userMask: error_data[:userMask],
        browserName: error_data[:browserName],
        fullVersion: error_data[:fullVersion],
        majorVersion: error_data[:majorVersion],
        appName: error_data[:appName],
        userAgent: error_data[:userAgent],
        name: error_data[:name],
        message: error_data[:message],
        file: error_data[:file],
        line: error_data[:line],
        column: error_data[:column],
        url: error_data[:url],
        errorStack: error_data[:errorStack]
      }
    )
  end

  # takes {tag: <:sym>, subject: <"str">, body: <{}>}
  def self.notify(options)
    SystemMailer.notification(options).deliver
  end
end
