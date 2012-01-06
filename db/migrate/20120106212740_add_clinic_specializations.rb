class AddClinicSpecializations < ActiveRecord::Migration
  def change
    create_table :clinic_specializations do |t|
      t.integer :clinic_id
      t.integer :specialization_id
      
      t.timestamps
    end
    
    Clinic.all.each { 
      |c| ClinicSpecialization.create(:clinic_id => c.id,
                                      :specialization_id => c.specialization_id)
    }
    
    #TODO when it all works
    #remove_column :clinics, :specialization_id
  end
end
