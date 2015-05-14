class Array
  def unique_push(elem)
    self << elem unless self.include?(elem)

    self
  end
end
