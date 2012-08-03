class AddUserTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :type_mask, :integer, :default => 1
  end
end
