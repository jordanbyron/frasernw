class Focus < ActiveRecord::Base
  attr_accessible :investigation
  
  belongs_to :clinic
  belongs_to :procedure
  
  has_paper_trail
end
