class DivisionReferralCity < ActiveRecord::Base
  belongs_to :division
  belongs_to :city

  has_many :division_referral_city_specializations, :dependent => :destroy
  has_many :specializations, :through => :division_referral_city_specializations

  include PaperTrailable
  include ActionView::Helpers::FormOptionsHelper

  def self.save_all_for_division(division, proximities)
    City.all.each do |city|
      division_referral_city = DivisionReferralCity.
        find_or_initialize_by_division_id_and_city_id(division.id, city.id)

      division_referral_city.proximity = proximities[city.id] || 1
      division_referral_city.save
    end
  end

  def options_for_proximity_select
    options_for_select(
      City.proximity_setting_options,
      selected: self.proximity
    )
  end
end
