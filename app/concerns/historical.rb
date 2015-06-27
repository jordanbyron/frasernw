# mixin for models so that we can call #history on them

module Historical
  def history
    history_generator.exec
  end

  def history_generator
    history_generator_klass.new(self)
  end

  def history_generator_klass
    "GenerateHistory::#{self.klass}".constantize
  end
end
