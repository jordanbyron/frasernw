class Focus < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :procedure_specialization

  WAITTIME_LABELS = Clinic::WAITTIME_LABELS
  LAGTIME_LABELS = Clinic::LAGTIME_LABELS

  include PaperTrailable

  delegate :procedure, to: :procedure_specialization

  def self.clinic_wait_time
    joins(:procedure_specialization).
      where('procedure_specializations.clinic_wait_time = (?)', true)
  end

  def waittime
    WAITTIME_LABELS[waittime_mask].present? ? WAITTIME_LABELS[waittime_mask] : ""
  end

  def lagtime
    LAGTIME_LABELS[lagtime_mask].present? ? LAGTIME_LABELS[lagtime_mask] : ""
  end
end
