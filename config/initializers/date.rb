class Date
  def previous_monday
    self + (1 - self.wday).days
  end
end
