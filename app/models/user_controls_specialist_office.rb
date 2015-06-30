class UserControlsSpecialistOffice < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :specialist_office, touch: true

  include PaperTrailable
end
