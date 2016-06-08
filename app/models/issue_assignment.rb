class IssueAssignment < ActiveRecord::Base
  attr_accessible :assignee_id, :issue_id

  belongs_to :assignee, class_name: "User"
  belongs_to :issue
end
