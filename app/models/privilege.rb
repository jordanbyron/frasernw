class Privilege < ActiveRecord::Base
  belongs_to :specialist, touch: true
  belongs_to :hospital
  has_paper_trail
end
