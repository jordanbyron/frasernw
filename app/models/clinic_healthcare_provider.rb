class ClinicHealthcareProvider < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :healthcare_provider

  include PaperTrailable
end
