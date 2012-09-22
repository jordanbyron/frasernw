class RemoveInlineFromScItem < ActiveRecord::Migration
  def change
    remove_column :sc_items, :inline
  end
end
