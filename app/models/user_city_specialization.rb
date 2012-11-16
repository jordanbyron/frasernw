class UserCitySpecialization < ActiveRecord::Base
  belongs_to :user_city
  belongs_to :specialization

  has_paper_trail
end
