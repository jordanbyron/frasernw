class CreateDivision < ActiveRecord::Migration
  def change
    create_table :division_cities do |t|
      t.integer :division_id
      t.integer :city_id
      
      t.timestamps
    end
    
    create_table :divisions do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
