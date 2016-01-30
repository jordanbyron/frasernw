class AddSuffixToSpecialization < ActiveRecord::Migration
  def up
    add_column :specializations, :suffix, :string
  end

  def down
    remove_column :specializations, :suffix, :string
  end
end
