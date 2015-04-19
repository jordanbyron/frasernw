class UserControlsClinic < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :clinic, touch: true

  has_paper_trail
end
