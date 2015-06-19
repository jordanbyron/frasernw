class RemoveSpecialistAddressUpdate < ActiveRecord::Migration
  def up
    remove_column :specialists, :address_update
  end

  def down
    add_column :specialists, :address_update, :text
  end
end
