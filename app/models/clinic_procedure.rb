class ClinicProcedure < ActiveRecord::Base
  include HasWaitTime

  belongs_to :clinic
  belongs_to :procedure

  # TODO: remove

  belongs_to :procedure_specialization

  #

  # WAITTIME_LABELS = Clinic::WAITTIME_LABELS
  # LAGTIME_LABELS = Clinic::LAGTIME_LABELS

  include PaperTrailable

  def self.clinic_has_wait_time
    joins(:procedure).where(clinic_has_wait_time: true)
  end
end
