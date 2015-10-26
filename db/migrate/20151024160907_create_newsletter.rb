class CreateNewsletter < ActiveRecord::Migration
  def up
    create_table :newsletters do |t|
      t.integer :month_key, null: false
      t.has_attached_file :document

      t.timestamps
    end
    add_index :newsletters, [:month_key], name: "newsletters_month_key"

    create_table :newsletter_description_items do |t|
      t.text :description_item
      t.integer :newsletter_id

      t.timestamps
    end
    add_index :newsletter_description_items,
      [:newsletter_id],
      name: "newsletter_description_items_newsletter_id"
  end

  def down
    drop_table :newsletters
    drop_table :newsletter_description_items
  end
end
