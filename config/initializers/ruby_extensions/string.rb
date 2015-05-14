class String
  def safe_for_filename
    self.
      gsub(/[^\w\s_-]+/, '').
      gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').
      gsub(/\s+/, '_')
  end
end
