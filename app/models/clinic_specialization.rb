class ClinicSpecialization < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :specialization

  include PaperTrailable
end
