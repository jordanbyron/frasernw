class DeleteFront < ActiveRecord::Migration
  def up
    drop_table(:fronts)
    remove_column(:featured_contents, :front_id)
    FeaturedContent.where(sc_item_id: nil).destroy_all
  end

  def down
  end
end
