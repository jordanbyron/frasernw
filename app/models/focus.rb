class Focus < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :procedure_specialization
  
  has_paper_trail
end
