class LanguageSweeper < PathwaysSweeper
  observe Language

  def expire_self(entity)
    expire_fragment language_path(entity)
  end
end