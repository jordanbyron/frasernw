class AddAncestryToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :ancestry, :string
    add_index :procedures, :ancestry
  end
end
