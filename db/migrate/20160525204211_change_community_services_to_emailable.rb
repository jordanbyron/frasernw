class ChangeCommunityServicesToEmailable < ActiveRecord::Migration
  def change
    ScItem.where(sc_category_id: 38).each do |community_service|
      community_service.can_email = true
      community_service.save
    end
  end
end
