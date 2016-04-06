class SanitizeReviewItems < ActiveRecord::Migration
  def up
    ReviewItem.all.each do |item|
      if item.base_object && item.base_object[/\u2028|\u2029/]
        puts "Sanitizing base object for #{item.id}"

        item.update_attribute(
          :base_object,
          item.base_object.safe_for_javascript
        )
      end

      if item.object && item.object[/\u2028|\u2029/]
        puts "Sanitizing review object for #{item.id}"

        item.update_attribute(
          :object,
          item.object.safe_for_javascript
        )
      end
    end
  end

  def down
  end
end
