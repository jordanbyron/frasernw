class SpecialistAddress < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :address

  has_paper_trail
end
