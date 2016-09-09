class RenameSubscriptionClassification < ActiveRecord::Migration
  def up
    rename_column :classification, :target_class

    Subscription.
      where(target_class: "News Update").
      update_all(target_class: "NewsItem")

    Subscription.
      where(target_class: "ResourceUpdate").
      update_all(target_class: "ScItem")
  end
end
