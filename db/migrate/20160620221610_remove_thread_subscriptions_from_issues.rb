class RemoveThreadSubscriptionsFromIssues < ActiveRecord::Migration
  def up
    remove_column :issues, :subscribed_thread_subject
    remove_column :issues, :subscribed_thread_participants
  end
end
