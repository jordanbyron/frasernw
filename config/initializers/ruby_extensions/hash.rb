class Hash
  def clone
    begin
      Marshal.load(Marshal.dump(self))
    rescue
      super
    end
  end

  def all_values(new_value)
    new_hash = self.dup

    new_hash.each do |k, v|
      new_hash[k] = new_value
    end

    new_hash
  end

  def match?(other_hash, keys)
    keys.all? do |key|
      self[key] == other_hash[key]
    end
  end

  def lazy_match?(other_hash)
    other_hash.keys.all? do |key|
      self[key] == other_hash[key] || self[key].to_s == other_hash[key].to_s
    end
  end

  def camelize_keys
    to_a.map{|pair| [ pair[0].camelize(:lower), pair[1] ] }.to_h
  end
end
