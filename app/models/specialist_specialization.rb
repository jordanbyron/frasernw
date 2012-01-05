class SpecialistSpecialization < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :specialization
  
  has_paper_trail
end
