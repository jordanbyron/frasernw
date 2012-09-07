class AddActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :default => true
    add_column :users, :failed_login_count, :integer, :default => 0
  end
end
