class AddNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.boolean :breaking
      t.date :start_date
      t.date :end_date, :default => nil
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
