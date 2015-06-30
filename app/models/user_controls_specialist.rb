class UserControlsSpecialist < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :specialist, touch: true

  include PaperTrailable
end
