class AddThreadSubscriptionsToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :subscribed_thread_subject, :string
    add_column :issues, :subscribed_thread_participants, :string
  end
end
