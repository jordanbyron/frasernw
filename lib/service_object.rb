class ServiceObject
  include Virtus.model(strict: true)
  include ApplicationJob

  def self.call(args = {})
    if args[:delay]
      args.delete(:delay)

      Delayed::Job.enqueue(new(args))
    else
      args.delete(:delay)

      new(args).call
    end
  end

  def call
    raise NotImplementedError
  end

  def perform
    call
  end
end
