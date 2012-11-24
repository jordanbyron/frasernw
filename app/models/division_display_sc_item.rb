class DivisionReferralCitySpecialization < ActiveRecord::Base
  belongs_to :division
  belongs_to :sc_item

  has_paper_trail
end
