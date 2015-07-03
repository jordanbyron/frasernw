class SeedFaqCategories < ActiveRecord::Migration
  def up
    FaqCategory.create(name: "Help")
    FaqCategory.create(name: "Privacy")
  end

  def down
    FaqCategory.where(name: "Help").destroy_all
    FaqCategory.where(name: "Privacy").destroy_all
  end
end
