class ClinicSpeak < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :language

  include PaperTrailable
end
