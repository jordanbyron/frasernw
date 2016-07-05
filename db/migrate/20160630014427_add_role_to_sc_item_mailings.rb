class AddRoleToScItemMailings < ActiveRecord::Migration
  def up
    add_column :sc_item_mailings, :user_role, :string
  end
end
