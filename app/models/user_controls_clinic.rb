class UserControlsClinic < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :clinic, touch: true

  include PaperTrailable
end
