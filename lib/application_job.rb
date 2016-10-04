module ApplicationJob
  def perform
    raise NotImplementedError
  end

  def error(job, exception)
    SystemNotifier.error(exception)
  end
end
