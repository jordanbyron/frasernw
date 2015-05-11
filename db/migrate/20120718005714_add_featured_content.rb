class AddFeaturedContent < ActiveRecord::Migration
  def change

    create_table :featured_contents do |t|
      t.integer :sc_category_id
      t.integer :sc_item_id
      t.integer :front_id

      t.timestamps
    end

    create_table :fronts do |t|

      t.timestamps
    end

  end
end
