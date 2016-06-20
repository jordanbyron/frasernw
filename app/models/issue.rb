class Issue < ActiveRecord::Base
  include PaperTrailable

  attr_accessible :description,
    :source_key,
    :effort_estimate,
    :progress_key,
    :priority,
    :manual_date_entered,
    :manual_date_completed,
    :issue_assignments_attributes,
    :title,
    :subscriptions_attributes,
    :subscribed_thread_subject,
    :subscribed_thread_participants,
    :source_id,
    :complete_this_weekend,
    :complete_next_meeting

  has_many :issue_assignments, dependent: :destroy
  has_many :assignees, through: :issue_assignments, class_name: "User"

  has_many :subscriptions, dependent: :destroy, class_name: "IssueSubscription"
  has_many :subscribers, through: :subscriptions, class_name: "User"

  accepts_nested_attributes_for :issue_assignments,
    allow_destroy: true

  accepts_nested_attributes_for :subscriptions,
    allow_destroy: true

  def self.change_request
    where(source_key: 1)
  end

  PROGRESS_LABELS = {
    1 => "Not started",
    2 => "In progress",
    3 => "Design consultation",
    4 => "Complete",
    5 => "Re-examine need",
    6 => "Ready to Test",
    7 => "Cancelled"
  }
  def progress
    PROGRESS_LABELS[progress_key]
  end

  def completed?
    progress_key == 4
  end

  def completion_estimate
    if complete_this_weekend?
      "<= This Weekend"
    elsif complete_next_meeting?
      "<= Next U.G. Meeting"
    else
      "> Next U.G. Meeting"
    end
  end

  EFFORT_ESTIMATES = ["-", "L", "M", "H"]

  SOURCE_LABELS = {
    1 => "Change Request",
    2 => "User Group Agenda Item",
    3 => "Provincial Team Request",
    4 => "Developers",
    5 => "Bug Report"
  }
  BRIEF_SOURCE_LABELS = {
    1 => "CR",
    2 => "Agenda",
    3 => "Req",
    4 => "Dev",
    5 => "Bug"
  }
  def source
    SOURCE_LABELS[source_key]
  end

  def change_request?
    source_key == 1
  end

  def date_entered
    manual_date_entered || created_at.to_date
  end

  def date_completed
    manual_date_completed || version_marked_completed.try(:created_at)
  end

  def version_marked_completed
    versions.select do |version|
      version.changeset["progress"].present? &&
        version.changeset["progress"][0] != 4 &&
        version.changeset["progress"][1] == 4
    end.last
  end

  def label(numbered: true)
    if numbered
      "##{id} - #{title.present? ? title : description}"
    else
      title.present? ? title : description
    end
  end

  def assignees_label
    assignees.
      map(&:name).
      map{|name| name[/[^\s]+/] }.
      sort.
      to_sentence
  end

  def to_hash
    attributes.except(:date_entered, :date_completed).camelize_keys.merge({
      assigneeIds: assignees.map(&:id).sort,
      collectionName: "issues",
      dateEntered: date_entered.to_s,
      dateCompleted: date_completed.try(:to_s)
    })
  end
end
