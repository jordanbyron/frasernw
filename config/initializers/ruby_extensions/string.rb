class String
  def safe_for_filename
    self.
      gsub(/[^\w\s_-]+/, '').
      gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').
      gsub(/\s+/, '_')
  end

  # "2011-1"
  def to_month
    year_month = self.split("-")

    Month.new(
      year_month[0].to_i,
      year_month[1].to_i
    )
  end
end
