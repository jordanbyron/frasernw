class AddSavedTokens < ActiveRecord::Migration
  def change
    add_column :specializations, :saved_token, :string
    add_column :clinics, :saved_token, :string
    add_column :hospitals, :saved_token, :string
    add_column :procedures, :saved_token, :string
    add_column :languages, :saved_token, :string
  end
end
