class DivisionSpecializationCity < ActiveRecord::Base
  belongs_to :division_specialization
  belongs_to :city

  has_paper_trail
end
