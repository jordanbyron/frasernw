class ClinicAddress < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :address
  
  has_paper_trail
end
