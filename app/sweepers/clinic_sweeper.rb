class ClinicSweeper < PathwaysSweeper
  observe Clinic
  
  def expire_self(entity)
    expire_fragment clinic_path(entity)
  end 
end