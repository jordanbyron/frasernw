class SaveAllDivisionReferralCities < ActiveRecord::Migration
  def up
    Division.all.each do |division|
      DivisionReferralCity.save_all_for_division(division)
    end
  end

  def down
  end
end
