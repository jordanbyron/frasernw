class Setting < ActiveRecord::Base
  IDENTIFIERS = {
    localstorage_cache_version: 1
  }

  def self.find_by_key(key)
    where(identifier: IDENTIFIERS[key]).first
  end

  def self.fetch(key)
    find_by_key(key).value
  end

  def self.update(key, value)
    find_by_key(key).update_attribute(:value, value)
  end

  def self.increment(key)
    record = find_by_key(key)
    record.update_attribute(:value, (record.value + 1))
  end
end
