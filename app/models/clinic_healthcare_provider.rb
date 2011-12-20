class ClinicHealthcareProvider < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :healthcare_provider
  
  has_paper_trail
end
