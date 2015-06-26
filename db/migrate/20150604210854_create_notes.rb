class CreateNotes < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.text :content
      t.belongs_to :user
      t.belongs_to :noteable, :polymorphic => true, index: true

      t.timestamps
    end
  end

  def down
    drop_table :notes
  end
end
