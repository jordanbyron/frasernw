# We don't know anything about the user, not even whether they are logged-in
class UnknownUser
  def name
    "an unidentified user"
  end

  def divisions
    []
  end

  def known?
    false
  end
end
