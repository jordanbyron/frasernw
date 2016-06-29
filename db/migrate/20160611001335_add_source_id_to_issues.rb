class AddSourceIdToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :source_id, :string
  end
end
