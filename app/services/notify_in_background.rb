class NotifyInBackground < ServiceObject
  attribute :options

  def call
    SystemMailer.notification(options).deliver
  end

  def error
  end
end
