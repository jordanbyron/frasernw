class Issue < ActiveRecord::Base

  attr_accessible :description,
    :source_key,
    :estimate_key,
    :progress_key,
    :manual_date_entered

  PROGRESS_LABELS = {
    1 => "Not started",
    2 => "In progress",
    3 => "In progress/delayed",
    5 => "Complete"
  }
  def progress
    PROGRESS_LABELS[progress_key]
  end

  COMPLETION_ESTIMATE_LABELS = {
    1 => "This weekend",
    2 => "Next weekend",
    3 => "Next U.G. meeting",
    4 => "After next U.G. meeting"
  }
  def completion_estimate
    COMPLETION_ESTIMATE_LABELS[estimate_key]
  end

  SOURCE_LABELS = {
    1 => "Change Request",
    2 => "User Group Agenda Item",
    3 => "Provincial Team Request",
    4 => "Technical Issue",
    5 => "Bug"
  }
  def source
    SOURCE_LABELS[source_key]
  end

  def date_entered
    manual_date_entered || created_at.to_date
  end
end
