class AddFeedbackItem < ActiveRecord::Migration
  def change
    create_table :feedback_items do |t|
      t.string :item_type
      t.integer :item_id
      t.integer :user_id
      t.text :feedback
      
      t.timestamps
    end
  end
end
