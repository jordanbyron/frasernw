class UserControlsClinic < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :clinic, touch: true

  include PaperTrailable

  def formatted_last_visited
    last_visited.strftime("%B %-d, %Y")
  end
end
