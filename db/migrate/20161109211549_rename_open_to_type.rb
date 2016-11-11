class RenameOpenToType < ActiveRecord::Migration
  def change
    rename_column :specialization_options, :open_to_type, :open_to_type_key
  end
end
