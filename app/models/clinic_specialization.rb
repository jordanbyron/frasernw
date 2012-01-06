class ClinicSpecialization < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :specialization
  
  has_paper_trail
end
