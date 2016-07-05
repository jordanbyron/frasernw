class RenameInProgress < ActiveRecord::Migration
  def up
    rename_column :specialization_options, :in_progress, :hide_from_division_users
  end
end
