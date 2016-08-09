class UpdateChoosingWiselyAncestryToPearls < ActiveRecord::Migration
  def up
    choosing_wisely = ScCategory.where(name: "Choosing Wisely").first
    pearls = ScCategory.where(name: "Pearls").first
    choosing_wisely.update_attribute(:ancestry, pearls.id.to_s)
  end

  def down
    choosing_wisely = ScCategory.where(name: "Choosing Wisely").first
    physician_resources = ScCategory.where(name: "Physician Resources").first
    choosing_wisely.update_attribute(:ancestry, physician_resources.id.to_s)
  end
end
