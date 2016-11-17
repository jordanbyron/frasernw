class ClinicProcedure < ActiveRecord::Base
  include HasWaitTimes

  belongs_to :clinic
  belongs_to :procedure

  attr_accessible :clinic_id,
    :investigation,
    :procedure_id

  # TODO: remove

  belongs_to :procedure_specialization

  #

  # WAITTIME_LABELS = Clinic::WAITTIME_LABELS
  # LAGTIME_LABELS = Clinic::LAGTIME_LABELS

  include PaperTrailable

  def self.clinic_has_wait_time
    joins(:procedure).where(clinic_has_wait_time: true)
  end

  def specifies_wait_times?
    procedure.clinics_specify_wait_times
  end
end
