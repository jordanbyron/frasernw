class AddScCategories < ActiveRecord::Migration
  def change
    create_table :sc_categories do |t|
      t.string :name
      
      t.timestamps
    end
    
    categories = ["Risk Calculators", "Care Pathways", "Pearls", "Red Flags", "Patient Education"]
    categories.each do |category|
      sc_category = ScCategory.new
      sc_category.name = category
      sc_category.save
    end
  end
end
