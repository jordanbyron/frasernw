class CreateUserMasks < ActiveRecord::Migration
  def up
    create_table :user_masks do |t|
      t.integer :user_id, null: false
      t.string :role

      t.timestamps
    end

    create_table :user_mask_divisions do |t|
      t.integer :division_id
      t.integer :user_mask_id

      t.timestamps
    end
  end

  def down
    drop_table :user_masks
    drop_table :user_mask_divisions
  end
end
