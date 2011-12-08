class ClinicSpeak < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :language
  has_paper_trail
end
