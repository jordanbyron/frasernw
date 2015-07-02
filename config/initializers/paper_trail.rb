class Version < ActiveRecord::Base
  # nice past tense events for paper_trail
  def evented
    self.event.gsub('update','updated').gsub('destroy','destroyed').gsub('create','created')
  end

  def safe_user
    User.safe_find(
      self.whodunnit,
      UnauthenticatedUser.new
    )
  end
end
