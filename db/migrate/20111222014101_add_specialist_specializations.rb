class AddSpecialistSpecializations < ActiveRecord::Migration
  def change
    create_table :specialist_specializations do |t|
      t.integer :specialist_id
      t.integer :specialization_id
      
      t.timestamps
    end
    
    Specialist.all.each { 
      |s| SpecialistSpecialization.create(:specialist_id => s.id,
                                          :specialization_id => s.specialization_id)
    }
    
    #TODO when it all works
    #remove_column :specialists, :specialization_id
  end
end
