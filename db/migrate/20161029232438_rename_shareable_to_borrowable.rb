class RenameShareableToBorrowable < ActiveRecord::Migration
  def change
    rename_column :sc_items, :shareable, :borrowable
  end
end
