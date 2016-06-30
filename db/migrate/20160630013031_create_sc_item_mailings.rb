class CreateScItemMailings < ActiveRecord::Migration
  def change
    create_table :sc_item_mailings do |t|
      t.integer :sc_item_id
      t.text :user_division_ids, array: true, default: []
      t.integer :user_id

      t.timestamps
    end
  end
end
