class ProvinceSweeper < PathwaysSweeper
  observe Province
  
  def expire_self(entity)
    #provinces aren't cached
  end 
  
  def add_to_lists(province)
    #only specialists and clinic index cards list the province
    province.addresses.each do |a|
      a.offices.each do |o|
        @specialists << o.specialists.map{ |s| s.id }
      end
      @clinics << (a.clinics + a.clinics_in_hospitals).map{ |c| c.id }
    end
  end
end