class FixTeleservices < ActiveRecord::Migration
  def change
    change_column :teleservices, :teleservice_provider_type, :string
    rename_column :teleservices, :service_type, :service_type_key
  end
end
