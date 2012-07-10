class OfficeSweeper < PathwaysSweeper
  observe Office
  
  def expire_self(entity)
    #offices aren't cached
  end 
  
  def add_to_lists(office)
    #expire all specializations of specialists in the office (they list the city)
    @specializations << office.specializations.map { |s| s.id }
    
    #expire all procedures of specialists in the office (they list the city)
    @procedures << office.procedures.map{ |p| p.id }
    
    #expire all specialists in the office
    @specialists << office.specialists.map{ |s| s.id }
    
    #expire all hospital pages of the specialists (they list the city)
    @hospitals << office.hospitals.map{ |h| h.id }
    
    #expire all language pages of the specialists (they list the city)
    @languages << office.languages.map{ |l| l.id }
  end
end