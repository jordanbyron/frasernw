class CollapseOffices < ActiveRecord::Migration
  def cleanup_address(address)
    return address.sub('avenue', 'ave').sub('street', 'st').sub('.',' ').sub('-',' ').delete(' ')
  end
  
  def change
    Office.all.each do |o1|
      
      specialist1 = o1.specialists.first
      next if specialist1.blank?
      
      l1 = o1.location
      next if l1.blank?
      
      if  !l1.in_hospital? && !l1.in_clinic?
        a1 = l1.resolved_address
        next if a1.blank?
        
        suite1 = a1.suite.strip.downcase
        address1 = cleanup_address(a1.address1.strip.downcase)
        city1 = a1.city
        
        next if address1.blank?
        next if city1.blank?
      end
      
      Office.all.each do |o2|
        
        next if o1.id == o2.id
        
        next if o2.specialists.length > 1
        specialist2 = o2.specialists.first
        
        l2 = o2.location
        next if l2.blank?
        
        if l2.in_hospital?
          next if l1.hospital_in != l2.hospital_in
          next if l1.suite_in != l2.suite_in
          next if l1.details_in != l2.details_in
          say "collapsing #{specialist1.name} and #{specialist2.name} at #{l1.suite_in}, #{l1.hospital_in.name}"
        elsif l2.in_clinic?
          next if l1.clinic_in != l2.clinic_in
          next if l1.suite_in != l2.suite_in
          next if l1.details_in != l2.details_in
          say "collapsing #{specialist1.name} and #{specialist2.name} at #{l1.suite_in}, #{l1.clinic_in.name}"
        else
          a2 = l2.resolved_address
          next if a2.blank?
        
          suite2 = a2.suite.strip.downcase
          address2 = cleanup_address(a2.address1.strip.downcase)
          city2 = a2.city
          
          next if suite1 != suite2
          next if address1 != address2
          next if city1 != city2
          
          say "collapsing #{specialist1.name} and #{specialist2.name} at #{a1.address}"
          
          #copy over any "extra" details
          a1.postalcode = a2.postalcode if a1.postalcode.blank?
          a1.address2 = a2.address2 if a1.address2.blank?
          a1.save
        end
        
        specialist2.offices.delete(o2)
        specialist2.offices << o1
        specialist2.save
        Office.delete(o2.id)
      end
    end
  end
end
