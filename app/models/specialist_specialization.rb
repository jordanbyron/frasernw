class SpecialistSpecialization < ActiveRecord::Base
  belongs_to :specialist, touch: true
  belongs_to :specialization

  include PaperTrailable
end
