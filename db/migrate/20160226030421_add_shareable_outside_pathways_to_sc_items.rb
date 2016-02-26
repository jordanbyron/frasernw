class AddShareableOutsidePathwaysToScItems < ActiveRecord::Migration
  TEAMS_CATEGORY_ID = 7
  INLINE_FILES_CATEGORY_ID = 10

  def up
    add_column :sc_items, :demoable, :boolean, default: false

    ScItem.where(
      "sc_items.sc_category_id NOT IN (?)",
      [ TEAMS_CATEGORY_ID, INLINE_FILES_CATEGORY_ID ]
    ).update_all(demoable: true)
  end

  def down
    remove_column :sc_items, :demoable
  end
end
