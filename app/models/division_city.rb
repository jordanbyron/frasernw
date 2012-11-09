class DivisionCity < ActiveRecord::Base
  belongs_to :division
  belongs_to :city

  has_paper_trail
end
