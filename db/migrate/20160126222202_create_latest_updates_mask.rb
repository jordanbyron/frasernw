class CreateLatestUpdatesMask < ActiveRecord::Migration
  def up
    create_table :latest_updates_masks do |t|
      t.integer :event_code
      t.integer :division_id
      t.date :date
      t.string :item_type
      t.integer :item_id

      t.timestamps
    end
  end

  def down
    drop_table :latest_updates_masks
  end
end
