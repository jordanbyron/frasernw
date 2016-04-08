class CleanupDivisionReferralCities < ActiveRecord::Migration
  def up
    DivisionReferralCity.all.each do |division_referral_city|
      if division_referral_city.city.nil?
        puts "destroying DRC ##{division_referral_city.id}, city_id: #{division_referral_city.city_id}"

        division_referral_city.destroy
      end
    end
  end

  def down
  end
end
