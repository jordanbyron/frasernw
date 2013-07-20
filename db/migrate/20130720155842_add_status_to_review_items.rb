class AddStatusToReviewItems < ActiveRecord::Migration
  def change
    add_column :review_items, :status, :integer, :default => 0
  end
end
