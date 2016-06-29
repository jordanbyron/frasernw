class ChangeCompletionEstimates < ActiveRecord::Migration
  def up
    add_column :issues, :complete_this_weekend, :boolean, default: false
    add_column :issues, :complete_next_meeting, :boolean, default: false

    Issue.
      all.
      select{|issue| issue.completion_estimate_key === 1}.
      each do |issue|
        issue.update_attributes(
          complete_this_weekend: true,
          complete_next_meeting: true
        )
      end

    Issue.
      all.
      select do |issue|
        [2, 3].include?(issue.completion_estimate_key)
      end.each do |issue|
        issue.update_attributes(
          complete_next_meeting: true
        )
      end

    remove_column :issues, :completion_estimate_key
  end
end
