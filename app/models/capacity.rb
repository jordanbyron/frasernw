class Capacity < ActiveRecord::Base
  attr_accessible :investigation
  attr_accessible :procedure
    
  belongs_to :specialist
  belongs_to :procedure_specialization
  
  has_paper_trail
end
