class Focus < ActiveRecord::Base
  belongs_to :clinic
  belongs_to :procedure_specialization

  has_paper_trail

  def self.clinic_wait_time
    joins(:procedure_specialization).where('procedure_specializations.clinic_wait_time = (?)', true)
  end

  def waittime
    Clinic::WAITTIME_HASH[waittime_mask].present? ? Clinic::WAITTIME_HASH[waittime_mask] : ""
  end

  def lagtime
    Clinic::LAGTIME_HASH[lagtime_mask].present? ? Clinic::LAGTIME_HASH[lagtime_mask] : ""
  end
end
