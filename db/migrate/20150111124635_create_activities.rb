# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :activities do |t|
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.string  :key
      t.text    :parameters
      t.belongs_to :recipient, :polymorphic => true

      ##custom fields added that were not default to public_activity gem:
      t.string :update_classification_type #e.g. News Update or Resource Update
      t.string :categorization #e.g. #NewsItem::TYPE_HASH
      t.integer :type_mask
      t.text :type_mask_description
      t.belongs_to :parent, :polymorphic => true #e.g. ScCategory -> ScItem, Division -> NewsItem

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
    add_index :activities, [:parent_id, :parent_type]
  end
  # Drop table
  def self.down
    drop_table :activities
  end
end
