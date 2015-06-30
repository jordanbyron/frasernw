class UserCitySpecialization < ActiveRecord::Base
  belongs_to :user_city
  belongs_to :specialization

  include PaperTrailable
end
