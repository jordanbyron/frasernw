class Hash
  def all_values(new_value)
    new_hash = self.dup

    new_hash.each do |k, v|
      new_hash[k] = new_value
    end

    new_hash
  end
end
