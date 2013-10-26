class AddClinicLocationAttendances < ActiveRecord::Migration
  def change
    
    rename_column :attendances, :clinic_id, :clinic_location_id
    
    Attendance.reset_column_information
  
    Attendance.all.each do |a|
      
      next if a.clinic_location_id.blank?
      
      clinic = Clinic.find_by_id(a.clinic_location_id)
      
      next if clinic.blank?
      
      clinic_locations = clinic.clinic_locations.reject{ |cl| cl.location.blank? || cl.location.empty? }
      
      next if clinic_locations.length == 0
      
      if clinic_locations.length > 1
        puts "Clinic " + clinic.name + " has more than one location"
      end
      
      a.clinic_location_id = clinic_locations.first.id
      a.save
      
    end
  end
end
