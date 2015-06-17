class SpecialistSpecialization < ActiveRecord::Base
  belongs_to :specialist, touch: true
  belongs_to :specialization

  has_paper_trail
end
