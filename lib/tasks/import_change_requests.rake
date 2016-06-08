require 'csv'

task import_change_requests: :environment do

  pending_file =
    File.read("/Users/briangracie/Code/frasernw/tmp/pending_change_requests.csv")

  pending_csv = CSV.parse(pending_file)

  pending_csv.drop(3).each do |row|
    Issue.create(
      description: row[1],
      title: row[4],
      manual_date_entered: Date.parse(row[2]),
      progress_key: Issue::PROGRESS_LABELS.key(row[3]),
      priority: row[6],
      source_key: 1,
      effort_estimate: row[7]
    )
  end

  complete_file =
    File.read("/Users/briangracie/Code/frasernw/tmp/completed_change_requests.csv")

  complete_csv = CSV.parse(complete_file)

  complete_csv.drop(3).each do |row|
    Issue.create(
      description: row[1],
      source_key: 1,
      progress_key: 4,
      manual_date_entered: (row[2].nil? || row[2] ? nil : Date.parse(row[2])),
      manual_date_completed: (row[3].nil? || row[3] ? nil : Date.parse(row[3]))
    )
  end

  dev_file =
    File.read("/Users/briangracie/Code/frasernw/tmp/dev_priorities.csv")

  dev_csv =
    CSV.parse(dev_file)

  dev_csv.drop(1).each do |row|
    next if row[1].include?("CR")

    source_key =
      if row[1].include?("Tech")
        4
      elsif row[1].include?("Req")
        3
      elsif row[1].include?("Bug")
        5
      end

    issue = Issue.create(
      source_key: source_key,
      title: row[4],
      description: row[3],
      progress_key: Issue::PROGRESS_LABELS.key(row[7]),
      manual_date_entered: (row[2].nil? || row[2] ? nil : Date.parse(row[2]))
    )

    if row[8] == "Brian"
      IssueAssignment.create(
        issue_id: issue.id,
        assignee_id: 3243
      )
    elsif row[8] == "Daniel"
      IssueAssignment.create(
        issue_id: issue.id,
        assignee_id: 4026
      )
    end
  end
end
