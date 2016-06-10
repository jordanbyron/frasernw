class CreateIssueSubscriptions < ActiveRecord::Migration
  def up
    create_table :issue_subscriptions do |t|
      t.integer :user_id
      t.integer :issue_id

      t.timestamps
    end
  end

  def down
    drop_table :issue_subscriptions
  end
end
