class AddActivedDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activated_at, :date
  end
end
