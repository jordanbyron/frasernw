class SpecialistProcedure < ActiveRecord::Base
  include HasWaitTime

  belongs_to :specialist
  belongs_to :procedure

  # TODO: remove

  belongs_to :procedure_specialization

  #

  # WAITTIME_LABELS = Specialist::WAITTIME_LABELS
  # LAGTIME_LABELS = Specialist::LAGTIME_LABELS

  include PaperTrailable

  def self.specialist_has_wait_time
    joins(:procedure).where(specialist_has_wait_time: true)
  end
end
