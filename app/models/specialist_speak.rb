class SpecialistSpeak < ActiveRecord::Base
  belongs_to :specialist, touch: true
  belongs_to :language

  has_paper_trail
end
