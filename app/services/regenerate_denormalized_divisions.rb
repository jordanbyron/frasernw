class RegenerateDenormalizedDivisions < ServiceObject
  def call
    Denormalized.regenerate(:divisions)
  end
end
