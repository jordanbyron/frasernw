class Setting < ActiveRecord::Base
  def self.localstorage_cache_version
    where(identifier: 1).first.value
  end
end
