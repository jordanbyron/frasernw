class AddTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :saved_token, :string
  end
end
