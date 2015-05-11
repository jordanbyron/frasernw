class AddAddressLineToAddresses < ActiveRecord::Migration
  def change
    rename_column :addresses, :address2, :suite
    add_column :addresses, :address2, :string
  end
end
