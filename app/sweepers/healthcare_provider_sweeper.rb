class HealthcareProviderSweeper < PathwaysSweeper
  observe HealthcareProvider
  
  def expire_self(entity)
    #healthcare providers aren't cached
  end 
  
  def add_to_lists(healthcare_provider)
    #expire all specializations, they list healthcare providers
    @specializations << Specialization.all.map { |s| s.id }
    
    #expire all procedures, they list healthcare providers
    @procedures << Procedure.all.map{ |p| p.id }
    
    #expire all clinics that the healthcare_provider is in
    @clinics << healthcare_provider.clinics.map{ |c| c.id }
  end
end