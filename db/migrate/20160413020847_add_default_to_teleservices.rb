class AddDefaultToTeleservices < ActiveRecord::Migration
  def change
    change_column :teleservices, :telephone, :boolean, default: false
    change_column :teleservices, :video, :boolean, default: false
    change_column :teleservices, :email, :boolean, default: false
    change_column :teleservices, :store, :boolean, default: false
  end
end
