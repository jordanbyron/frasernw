class UserControlsClinic < ActiveRecord::Base
  belongs_to :user
  belongs_to :clinic
  
  has_paper_trail
end
