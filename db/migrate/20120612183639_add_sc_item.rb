class AddScItem < ActiveRecord::Migration
  def change
    create_table :sc_item_specializations do |t|
      t.integer :sc_item_id
      t.integer :specialization_id
      
      t.timestamps
    end
    
    create_table :sc_items do |t|
      t.integer :sc_category_id
      t.string :name
      
      t.timestamps
    end
  end
end
