class UserControlsClinicLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :clinic_location
  
  has_paper_trail
end
