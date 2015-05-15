class Array
  # deep copy
  def clone
    Marshal.load(Marshal.dump(self))
  end

  def unique_push(elem)
    self << elem unless self.include?(elem)

    self
  end

  # based on a uniquing function
  def subsets(uniq_function)
    # we're going to gradually reduce this clone down as we pull out matching elements
    copy = self.clone

    self.inject([]) do |memo, elem|
      # get the items in the copy that match this one according to our function
      subset = copy.select do |inner_elem|
        uniq_function.call(inner_elem) == uniq_function.call(elem)
      end

      memo << subset if subset.any?

      # so we don't get duplicate dupe sets...
      copy.delete_if do |inner_elem|
        uniq_function.call(inner_elem) == uniq_function.call(elem)
      end

      memo
    end
  end
end
