# Wrapper around hash that support lazy comparisons of array keys

class ArrayDictionary
  attr_reader :hsh

  def initialize(hsh)
    @hsh = hsh
  end

  def find(ary_key)
    hsh.keys.each do |key|
      if key.sort == ary_key.sort
        return hsh[key.sort]
      end
    end
  end
end
