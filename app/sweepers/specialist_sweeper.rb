class SpecialistSweeper < PathwaysSweeper
  observe Specialist

  def expire_self(entity)
    expire_fragment specialist_path(entity)
  end
end