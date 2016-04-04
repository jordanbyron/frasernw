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

  def safe_for_javascript!
    gsub!(/\u2028/, "\\u2028")
    gsub!(/\u2029/, "\\u2029")
  end

  def safe_for_javascript
    gsub(/\u2028/, "\\u2028").
      gsub(/\u2029/, "\\u2029")
  end

  # "ReviewItem" => "Review Item"
  def split_on_capitals
    scan(/[A-Z][^A-Z]*/).join(' ')
  end
end
