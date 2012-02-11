class Capacity < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :procedure_specialization
  
  has_paper_trail
end
