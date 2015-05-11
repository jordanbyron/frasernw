class AddLocationInToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :location_in_id, :integer

    Location.all.each do |l|
      if (l.clinic_in_id)
        clinic = Clinic.find(l.clinic_in_id)
        l.location_in_id = Location.find_by_locatable_id_and_locatable_type(clinic.id, 'Clinic').id
        l.save
      end
    end
  end
end
