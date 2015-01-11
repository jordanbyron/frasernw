class AddCustomFieldToActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.string :update_classification_type #e.g. News Update or Resource Update
      t.string :categorization #e.g. #NewsItem::TYPE_HASH
      t.belongs_to :parent, :polymorphic => true #e.g. ScCategory -> ScItem
    end
  end
end
