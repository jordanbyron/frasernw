class SpecialistSpeak < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :language

  has_paper_trail
end
