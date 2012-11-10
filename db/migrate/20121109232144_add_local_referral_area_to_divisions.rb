class AddLocalReferralAreaToDivisions < ActiveRecord::Migration
  def change
    create_table :division_specializations do |t|
      t.integer :division_id
      t.integer :specialization_id
      
      t.timestamps
    end
    
    create_table :division_specialization_cities do |t|
      t.integer :division_specialization_id
      t.integer :city_id
      
      t.timestamps
    end
  end
end
