class DivisionReferralCitySpecialization < ActiveRecord::Base
  belongs_to :division_referral_city
  belongs_to :specialization

  include PaperTrailable

  def city_id
    division_referral_city.city_id
  end
end
