class RemoveDeprecatedAddresses < ActiveRecord::Migration
  def up
    drop_table :specialist_addresses
    drop_table :clinic_addresses
  end

  def down

  end
end
