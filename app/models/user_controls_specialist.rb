class UserControlsSpecialist < ActiveRecord::Base
  belongs_to :user
  belongs_to :specialist
  
  has_paper_trail
end
