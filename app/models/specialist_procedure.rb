class SpecialistProcedure < ActiveRecord::Base
  include HasWaitTimes

  belongs_to :specialist
  belongs_to :procedure

  attr_accessible :specialist_id,
    :investigation,
    :procedure_id
  # TODO: remove

  belongs_to :procedure_specialization

  #

  # WAITTIME_LABELS = Specialist::WAITTIME_LABELS
  # LAGTIME_LABELS = Specialist::LAGTIME_LABELS

  include PaperTrailable

  def self.specialist_has_wait_time
    joins(:procedure).where(specialist_has_wait_time: true)
  end

  def specifies_wait_times?
    procedure.specialists_specify_wait_times
  end
end
