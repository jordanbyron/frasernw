class AddInlineToScItem < ActiveRecord::Migration
  def change
    add_column :sc_items, :inline, :boolean
  end
end
