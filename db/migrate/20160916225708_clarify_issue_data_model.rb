class ClarifyIssueDataModel < ActiveRecord::Migration
  def up
    Issue.where(source_key: 5).update_all(source_key: 3)
  end
end
