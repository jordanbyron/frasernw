class AddOwnerAndShareableToContentItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :division_id, :integer
    add_column :sc_items, :shareable, :boolean, :default => true
    
    create_table :division_display_scitem do |t|
      t.integer :division_id
      t.integer :sc_item_id
      
      t.timestamps
    end
    
  end
end
