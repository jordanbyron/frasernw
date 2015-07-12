# mixin for models so that we can call #history on them

module Historical
  def history
    GenerateHistory.new(self).exec
  end
end
