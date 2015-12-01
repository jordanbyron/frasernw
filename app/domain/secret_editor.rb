class SecretEditor
  def initialize(name = nil)
    @name = name
  end

  def name
    @name || "A secret edit link user"
  end
end
