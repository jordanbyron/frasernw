class ServiceObject
  include Virtus.model(strict: true)
  include ApplicationJob
  attribute :paper_trail_whodunnit

  def self.call(args = {})
    if args[:delay]
      Delayed::Job.enqueue(new(
        args.except(:delay).merge(paper_trail_whodunnit: PaperTrail.whodunnit)
      ))
    else
      new(args.except(:delay)).call
    end
  end

  def call
    raise NotImplementedError
  end

  def perform
    PaperTrail.whodunnit = paper_trail_whodunnit

    call
  end
end
