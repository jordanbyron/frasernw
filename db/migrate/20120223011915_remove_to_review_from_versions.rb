class RemoveToReviewFromVersions < ActiveRecord::Migration
  def change
    remove_column :versions, :to_review
  end
end
