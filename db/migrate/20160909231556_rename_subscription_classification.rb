class RenameSubscriptionClassification < ActiveRecord::Migration
  def up
    rename_column :subscriptions, :classification, :target_class

    Subscription.
      where(target_class: "News Updates").
      update_all(target_class: "NewsItem")

    Subscription.
      where(target_class: "Resource Updates").
      update_all(target_class: "ScItem")
  end
end
