class Privilege < ActiveRecord::Base
  belongs_to :specialist, touch: true
  belongs_to :hospital
  include PaperTrailable
end
