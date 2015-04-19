class UserControlsSpecialistOffice < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :specialist_office, touch: true

  has_paper_trail
end
