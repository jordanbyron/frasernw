class AddScItemTypeToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :sc_item_format_type, :string
  end
end
