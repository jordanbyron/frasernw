module ExpireFragment
  def self.call(key)
    Rails.cache.delete("views/#{key}")
  end
end
