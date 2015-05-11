class AddOwnerAndShareableToContentItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :division_id, :integer
    add_column :sc_items, :shareable, :boolean, :default => true

    create_table :division_display_sc_items do |t|
      t.integer :division_id
      t.integer :sc_item_id

      t.timestamps
    end

    ScItem.all.each do |item|
      item.division = Division.find(1) #all presently existing items belong to our first created division, the Fraser Northwest
      item.save
    end
  end
end
