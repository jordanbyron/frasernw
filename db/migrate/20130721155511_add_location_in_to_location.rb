class AddLocationInToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :location_in_id, :integer
    
    Location.all.each do |l|
      if (l.clinic_in_id)
        l.location_in_id = Clinic.find(l.clinic_in_id).locations.first
        l.save
      end
    end
  end
end
