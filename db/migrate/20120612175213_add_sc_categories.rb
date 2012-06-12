class AddScCategories < ActiveRecord::Migration
  def change
    create_table :sc_categories do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
