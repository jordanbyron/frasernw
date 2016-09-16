require 'rake/task'

module Rake
  class Task
    alias :orig_execute :execute
    def execute(args=nil)
      orig_execute(args)
    rescue Exception => exception
      ExceptionNotifier.notify_exception(exception)
      raise exception
    end
  end
end
