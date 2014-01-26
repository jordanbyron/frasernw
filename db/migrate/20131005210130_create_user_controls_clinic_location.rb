class CreateUserControlsClinicLocation < ActiveRecord::Migration
  def change
    create_table :user_controls_clinic_locations do |t|
      t.integer :user_id
      t.integer :clinic_location_id
      
      t.timestamps
    end
    
    UserControlsClinic.all.each do |ucc|
      UserControlsClinicLocation.create(:user => ucc.user, :clinic_location => ucc.clinic.clinic_locations.first);
    end
  end
end
