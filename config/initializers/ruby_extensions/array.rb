class Array
  # deep copy
  def clone
    Marshal.load(Marshal.dump(self))
  end

  def unique_push(elem)
    self << elem unless self.include?(elem)

    self
  end

  def dupe_sets(uniq_function)
    ary = self.clone

    ary.inject([]) do |memo, elem|
      inner_dupes = ary.inject([]) do |inner_memo, inner_elem|
        if uniq_function.call(elem) == uniq_function.call(inner_elem)
          inner_memo << ary.delete(inner_elem)
        end
        inner_memo
      end

      # one of those 'dupes' will be the original elem
      if inner_dupes.count > 1
        memo << inner_dupes
      end

      memo
    end
  end
end
