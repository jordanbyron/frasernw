class MakeMoreCommunityServicesEmailable < ActiveRecord::Migration
  def change
    community_services = ScItem.all.where(division_id: [3,17]) << ScItem.find(375)
    community_services.each do |community_service|
      community_service.can_email = true
      community_service.save
    end
  end
end
