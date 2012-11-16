class DivisionReferralCitySpecialization < ActiveRecord::Base
  belongs_to :division_referral_city
  belongs_to :specialization

  has_paper_trail
end
