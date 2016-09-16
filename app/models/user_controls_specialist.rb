class UserControlsSpecialist < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :specialist, touch: true

  include PaperTrailable

  def formatted_last_visited
    last_visited.strftime("%B %-d, %Y")
  end
end
