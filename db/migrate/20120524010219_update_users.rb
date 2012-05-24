class UpdateUsers < ActiveRecord::Migration
  def change
    remove_column :users, :username
    remove_column :users, :notify
  end
end
