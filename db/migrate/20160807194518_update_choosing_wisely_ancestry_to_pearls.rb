class UpdateChoosingWiselyAncestryToPearls < ActiveRecord::Migration
  def up
    choosing_wisely = ScCategory.where(name: "Choosing Wisely").first
    pearls = ScCategory.where(name: "Pearls").first
    choosing_wisely.update!(ancestry: pearls.id)
  end
  def down
    choosing_wisely = ScCategory.where(name: "Choosing Wisely").first
    physician_resources = ScCategory.where(name: "Physician Resources").first
    choosing_wisely.update!(ancestry: physician_resources.id)
  end
end
