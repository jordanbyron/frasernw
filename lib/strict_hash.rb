class StrictHash < Hash
  def initialize(hsh)
    super.update(hsh)
  end

  def [](key)
    if self.include?(key)
      super(key)
    else
      raise "Key '#{key}' not found"
    end
  end

  def key(val)
    if super(val).nil?
      raise "Key not found for value '#{val}'"
    else
      super(val)
    end
  end
end
