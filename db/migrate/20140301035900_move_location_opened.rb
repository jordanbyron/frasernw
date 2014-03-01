class MoveLocationOpened < ActiveRecord::Migration
  def change
    add_column :specialist_offices, :location_opened, :string
    add_column :clinic_locations, :location_opened, :string
    
    rename_column :specialists, :location_opened, :location_opened_old
    rename_column :clinics, :location_opened, :location_opened_old
    
    Specialist.all.each do |s|
      s.specialist_offices.each do |so|
        next if so.empty?
        so.location_opened = s.location_opened_old
        so.save
      end
    end
    
    Clinic.all.each do |c|
      c.clinic_locations.each do |cl|
        next if cl.empty?
        cl.location_opened = c.location_opened_old
        cl.save
      end
    end
  end
end
