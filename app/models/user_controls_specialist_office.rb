class UserControlsSpecialistOffice < ActiveRecord::Base
  belongs_to :user
  belongs_to :specialist_office
  
  has_paper_trail
end
