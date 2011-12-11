class Focus < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :procedure
  
  has_paper_trail
end
