class CreateReviewItems < ActiveRecord::Migration
  def change
    create_table :review_items do |t|
      t.string :item_type
      t.integer :item_id
      t.string :whodunnit
      t.text :object

      t.timestamps
    end
  end
end
