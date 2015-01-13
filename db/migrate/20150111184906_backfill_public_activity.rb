class BackfillPublicActivity < ActiveRecord::Migration
  def up
    NewsItem.find_each do |item|
      item.create_activity :create, update_classification_type: Subscription.news_update, type_mask: item.type_mask, type_mask_description: item.type, parent: item.division, owner: item.division
    end

    ScItem.find_each do |item|
      item.create_activity :create, update_classification_type: Subscription.resource_update, type_mask: item.type_mask, type_mask_description: item.type, parent: item.sc_category, owner: item.division
    end

  end

  def down
    PublicActivity::Activity.delete_all
  end
end
