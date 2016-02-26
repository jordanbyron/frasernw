class AddShareableOutsidePathwaysToScItems < ActiveRecord::Migration
  TEAMS_CATEGORY_ID = 7
  INLINE_FILES_CATEGORY_ID = 10

  def up
    add_column :sc_items, :visible_to_public, :boolean, default: true

    ScItem.where(
      "sc_items.sc_category_id IN (?)",
      [ TEAMS_CATEGORY_ID, INLINE_FILES_CATEGORY_ID ]
    ).update_all(visible_to_public: false)
  end

  def down
    remove_column :sc_items, :visible_to_public
  end
end
