require 'csv'

namespace :pathways do
  task :division_report, [:division, :start_date, :end_date] => :environment do |t, args|
    ### Defaults
    ### set for the K/B report atm
    args.with_defaults(
      start_date:  Date.civil(2015, 4, 16),
      end_date:    Date.civil(2015, 4, 30),
      division:    Division.find(7)
    )

    ### Get the data

    common_options = {
      start_date: args[:start_date],
      end_date:   args[:end_date],
      filters:    { division_id: args[:division].id }
    }

    total_pageviews =
      StatsReporter.page_views(common_options).first[:page_views]

    total_sessions = StatsReporter.sessions(common_options).first[:sessions]

    page_views_by_page =
      StatsReporter.page_views_by_page(common_options)

    page_views_table = Table.new(page_views_by_page)

    # collapse different users types for the same path down to one row per path
    page_views_table.collapse_duplicate_rows!(
      Proc.new { |row| row[:page_path] },
      {
        page_path: "",
        page_views: 0
      },
      Proc.new do |accumulator, row|
        accumulator[:page_path] = row[:page_path]
        accumulator[:page_views] += row[:page_views]
        accumulator[row[:user_type]] = row[:page_views]
      end
    )

    # add a column for resource type
    

    # add


    ### Write the CSV

    timestamp = DateTime.now.to_s
    filename  = [
      "pathways_usage_report",
      args[:division].name,
      timestamp,
    ].join("_").safe_for_filename + ".csv"
    file_path = Rails.root.join("reports", "divisions", filename)

    CSV.open(file_path, "w+") do |csv|
      csv << [ "Pathways Usage Report"]
      csv << [ "Division: #{args[:division].name}"]
      csv << [ "All Stats for Date Range:"]
      csv << [ ]
      csv << [ "Start Date"]
      csv << [ args[:start_date].to_s]
      csv << [ ]
      csv << [ "End Date"]
      csv << [ args[:end_date].to_s]
      csv << [ ]
      csv << [ ]
      csv << [ "Compiled on" ]
      csv << [ timestamp ]
      csv << [ ]
      csv << [ "Total Pageviews" ]
      csv << [ total_pageviews.to_s ]
      csv << [ ]
      csv << [ "Total Sessions" ]
      csv << [ total_sessions.to_s ]
      csv << [ ]
      csv << [ "Pageviews by Page" ]
      csv << [ "Path", "Pageviews" ]

      page_views_by_page.each do |row|
        csv << [ row[:page_path], row[:page_views] ]
      end
    end
  end
end
