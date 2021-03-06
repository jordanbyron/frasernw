class String

  def capitalize_first_letter
    self.strip!
    if self.length == 0
      self
    elsif self.length == 1
      self.capitalize
    else
      self.slice(0,1).capitalize + self.slice(1..-1)
    end
  end

  def uncapitalize_first_letter
    self.strip!
    if self.length == 0
      self
    elsif self.length == 1
      self.downcase
    elsif (self.length > 1) && (self.slice(1,1).upcase != self.slice(1,1))
      self.slice(0,1).downcase + self.slice(1..-1)
    else
      self
    end
  end

  def end_with_period
    self.strip!
    if self.length == 0
      self
    elsif self[-1,1] != '.'
      self + "."
    else
      self
    end
  end

  def strip_period
    self.strip!
    if self[-1,1] == '.'
      self[0..-2]
    else
      self
    end
  end

  def punctuate
    self.strip!
    if self.length == 0
      self
    else
      self.capitalize_first_letter.end_with_period
    end
  end

  def remove_whitespace
    self.gsub(/\s+/, "")
  end

  def convert_newlines_to_br
    self.gsub(/\r\n/, '<br>').html_safe
  end
end