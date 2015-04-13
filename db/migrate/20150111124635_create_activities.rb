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

      #############BEGIN devnote:
      # custom fields added that were not default to public_activity gem:
      t.string :update_classification_type #e.g. News Update or Resource Update
      t.integer :type_mask
      t.text :type_mask_description #e.g. #NewsItem::TYPE_HASH
      t.integer :format_type
      t.text :format_type_description

      t.belongs_to :parent, :polymorphic => true

      ## ScItem activity association guide:
      # Division :owner, ==>
      #                     #ScCategory#root_category :parent
      #                                                      #==> ScItem :trackable

      ## NewsItem activity association guide:
      # Division :parent, :owner ==>
      #                              NewsItem :trackable

      ############END

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
    add_index :activities, [:parent_id, :parent_type]
    add_index :activities, [:type_mask, :type_mask_description]
  end
  # Drop table
  def self.down
    drop_table :activities
  end
end
