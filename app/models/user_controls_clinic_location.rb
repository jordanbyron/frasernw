class UserControlsClinicLocation < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :clinic_location, touch: true

  include PaperTrailable
end
