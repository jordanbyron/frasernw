class AddAddressChangesForReview < ActiveRecord::Migration
  def change
    add_column :specialists, :address_update, :text
  end
end
