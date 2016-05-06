class AddLocationInToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :location_in_id, :integer

    Location.all.each do |l|
      if (l.clinic_in_id)
        clinic = Clinic.find(l.clinic_in_id)
        l.location_in_id = Location.find_by(
          locatable_id: clinic.id,
          locatable_type: 'Clinic'
        ).id
        l.save
      end
    end
  end
end
