class ChangeSubscriptionIntervalStringToInteger < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :interval
    Subscription.reset_column_information
    add_column :subscriptions, :interval, :integer
  end

  def down
    change_column :subscriptions, :interval, :string
    #add_column :subscriptions, :interval, :string
  end
end
