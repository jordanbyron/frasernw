class CreateFaqCategories < ActiveRecord::Migration
  def up
    create_table :faq_categories do |t|
      t.string :name, null: false

      t.timestamps
    end
  end

  def down
    drop_table :faq_categories
  end
end
