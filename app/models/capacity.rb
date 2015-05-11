class Capacity < ActiveRecord::Base
  belongs_to :specialist
  belongs_to :procedure_specialization

  has_paper_trail

  def self.specialist_wait_time
    joins(:procedure_specialization).where('procedure_specializations.specialist_wait_time = (?)', true)
  end

  def waittime
    Specialist::WAITTIME_HASH[waittime_mask].present? ? Specialist::WAITTIME_HASH[waittime_mask] : ""
  end

  def lagtime
    Specialist::LAGTIME_HASH[lagtime_mask].present? ? Specialist::LAGTIME_HASH[lagtime_mask] : ""
  end
end
