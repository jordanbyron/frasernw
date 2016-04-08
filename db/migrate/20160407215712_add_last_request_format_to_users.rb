class AddLastRequestFormatToUsers < ActiveRecord::Migration
  def up
    add_column :users, :last_request_format_key, :integer, default: 1
  end

  def down
    remove_column :users, :last_request_format_key
  end
end
