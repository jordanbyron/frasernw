class Hash
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
end
