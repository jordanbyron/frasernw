class RemoveDeprecatedInProgress < ActiveRecord::Migration
  def up
    remove_column :specializations, :deprecated_in_progress
  end
end
