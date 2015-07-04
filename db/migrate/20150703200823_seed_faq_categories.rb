class SeedFaqCategories < ActiveRecord::Migration
  def up
    FaqCategory.create(name: "Help")
    FaqCategory.create(
      name: "Privacy Compliance",
      description: "The following questions and answers outline how Pathways complies with British Columbia’s Personal Information Protection Act (PIPA) legislation. Privacy Officer contact information is also provided, should you have further questions."
    )
  end

  def down
    FaqCategory.where(name: "Help").destroy_all
    FaqCategory.where(name: "Privacy Compliance").destroy_all
  end
end
