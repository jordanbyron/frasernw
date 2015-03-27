class BackfillPublicActivity < ActiveRecord::Migration
  def up
    NewsItem.find_each do |item|
      item.create_activity action: :create, update_classification_type: Subscription.news_update, type_mask: item.type_mask, type_mask_description: item.type, parent_id: item.division.id, parent_type: "Division",  owner: item.division
    end

    ScItem.find_each do |item|
      item.create_activity action: :create, update_classification_type: Subscription.resource_update, type_mask: item.type_mask, type_mask_description: item.type, parent_id: item.sc_category.root.id, parent_type: item.sc_category.root.name, owner: item.division
      puts "sc_category root id:  #{item.sc_category.root.id}"
      puts "sc_category root type:  #{item.sc_category.root.name}"
    end

  end

  def down
    PublicActivity::Activity.delete_all
  end
end
