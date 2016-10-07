class StrictHash
  def initialize(wrapped)
    @wrapped = Hash.new{|hash, key| raise "Key #{key} doesn't exist" }.update(
      wrapped
    )
  end

  def method_missing(method, *args)
    @wrapped.send(method, *args)
  end
end
