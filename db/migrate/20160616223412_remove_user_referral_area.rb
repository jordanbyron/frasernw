class RemoveUserReferralArea < ActiveRecord::Migration
  def up
    drop_table :user_cities
    drop_table :user_city_specializations
  end
end
