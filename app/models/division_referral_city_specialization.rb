class DivisionReferralCitySpecialization < ActiveRecord::Base
  belongs_to :division_referral_city
  belongs_to :specialization

  include PaperTrailable
end
