class CitySweeper < PathwaysSweeper
  observe City
  
  def expire_self
    expire_fragment :controller => 'cities', :action => 'show'
  end 
  
  def add_to_lists(city)
    #expire all the clinics and specialists in the city, and their associated specializations, procedures, and languages (they list the city)
    city.addresses.each do |a|
      a.offices.each do |o|
        @specializations << o.specializations.map{ |s| s.id }
        @procedures << o.procedures.map{ |p| p.id }
        @specialists << o.specialists.map{ |s| s.id }
        @languages << o.languages.map{ |l| l.id }
      end
      (a.clinics + a.clinics_in_hospitals).each do |c|
        @specializations << c.specializations.map{ |s| s.id }
        @procedures << c.procedures.map{ |p| p.id }
        @clinics << c.id
        @languages << c.languages.map{ |l| l.id }
      end
      #expire hospitals in city
      @hospitals << a.hospitals.map{ |h| h.id }
    end
  end
end