class LanguageSweeper < PathwaysSweeper
  observe Language
  
  def expire_self(entity)
    expire_fragment language_path(entity)
  end 
  
  def add_to_lists(language)
    #expire all specializations (they list all languages)
    @specializations << Specialization.all.map { |s| s.id }
    
    #expire all procedures (they list all languages)
    @procedures << Procedure.all.map{ |p| p.id }
    
    #expire all specialists that speak the language
    @specialists << language.specialists.map{ |s| s.id }
    
    #expire all clinics that speak the language
    @clinics << language.clinics.map{ |c| c.id }
  end
end