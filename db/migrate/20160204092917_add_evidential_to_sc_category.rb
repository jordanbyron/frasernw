class AddEvidentialToScCategory < ActiveRecord::Migration
  def change
    # can have sc_item content that shows levels of evidence
    add_column :sc_categories, :evidential, :boolean
  end
end
