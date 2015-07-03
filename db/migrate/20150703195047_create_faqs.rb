class CreateFaqs < ActiveRecord::Migration
  def up
    create_table :faqs do |t|
      t.text :question, null: false
      t.text :answer_markdown, null: false
      t.integer :index, null: false
      t.integer :faq_category_id, null: false

      t.timestamps
    end

    add_index :faqs, [:faq_category_id], name: "faqs_category_id"
  end

  def down
    drop_table :faqs
  end
end
