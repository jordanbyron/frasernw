class HospitalSweeper < PathwaysSweeper
  observe Hospital

  def expire_self(entity)
    expire_fragment hospital_path(entity)
  end
end