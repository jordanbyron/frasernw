class DivisionUser < ActiveRecord::Base
  belongs_to :division
  belongs_to :user
  
  has_paper_trail
end
