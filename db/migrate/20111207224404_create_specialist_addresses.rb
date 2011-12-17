class CreateSpecialistAddresses < ActiveRecord::Migration
  def change
    create_table :specialist_addresses do |t|
      t.integer :specialist_id
      t.integer :address_id
      
      t.timestamps
    end
  end
end
