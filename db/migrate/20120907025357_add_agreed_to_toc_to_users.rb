class AddAgreedToTocToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agree_to_toc, :boolean, :default => false
  end
end
