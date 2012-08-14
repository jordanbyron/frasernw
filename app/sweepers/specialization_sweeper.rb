class SpecializationSweeper < PathwaysSweeper
  observe Specialization
  
  def expire_self(entity)
    expire_fragment specialization_path(entity)
  end 
end