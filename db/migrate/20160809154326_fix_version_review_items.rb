class FixVersionReviewItems < ActiveRecord::Migration
  def up
    # versions should link to the review item from which its changes originated
    # --> if the linked review item is newer than the version, that means
    # the link is incorrect

    Version.
      all.
      to_a.
      select do |version|
        version.review_item && version.review_item.created_at > version.created_at
      end.
      each{ |version| version.update_attribute(:review_item_id, nil) }
  end

  def down
  end
end
