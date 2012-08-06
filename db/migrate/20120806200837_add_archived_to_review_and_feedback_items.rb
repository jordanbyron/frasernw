class AddArchivedToReviewAndFeedbackItems < ActiveRecord::Migration
  def change
    add_column :review_items, :archived, :boolean, :default => false
    add_column :feedback_items, :archived, :boolean, :default => false
  end
end
