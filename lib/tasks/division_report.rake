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

    page_views_by_page = StatsReporter.page_views(
      common_options.merge(dimensions: [:page_path, :user_type_key])
    )

    page_views_table = Table.new(page_views_by_page)

    # we want all of the page views to be integers so we can do arithmetic on them
    page_views_table.transform_column!(:page_views) do |row|
      row[:page_views].to_i
    end

    current_user_type_hash = User::TYPE_HASH.merge(
      -1 => "Bounced",
      0 => "Admin"
    )

    # collapse different users types for the same path down to one row per path
    # with the user type breakdown as columns
    page_views_table.collapse_subsets!(
      Proc.new { |row| row[:page_path] },
      {
        page_path: "",
        page_views: 0
      }.merge(current_user_type_hash.all_values(0)),
      Proc.new do |accumulator, row|
        accumulator.dup.merge(
          :page_path => row[:page_path],
          :page_views => accumulator[:page_views] + row[:page_views],
          row[:user_type_key].to_i =>  row[:page_views]
        )
      end
    )

    ## users by user type

    # add a column for resource name



    # collapse specialists paths down
    page_views_table.collapse_subset!(
      Proc.new {|row| row[:page_path][/\/specialists/] },
      {
        page_path: "/specialists/*",
        page_views: 0
      }.merge(current_user_type_hash.all_values(0)),
      Proc.new do |accumulator, row|
        new_accumulator = accumulator.dup.merge(
          page_views: accumulator[:page_views] + row[:page_views],
        )

        current_user_type_hash.each do |key, value|
          if row[key].present?
            new_accumulator[key] = accumulator[key] + row[key]
          end
        end

        new_accumulator
      end
    )


    # collapse clinic names down

    # collapse user names down

    # sort by pathname


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
      csv << [ "Compiled on #{timestamp}" ]
      csv << [ "**All stats are for date range specified below***"]
      csv << [ ]
      csv << [ "Start Date"]
      csv << [ args[:start_date].to_s]
      csv << [ ]
      csv << [ "End Date"]
      csv << [ args[:end_date].to_s]
      csv << [ ]
      csv << [ "Total Pageviews" ]
      csv << [ total_pageviews.to_s ]
      csv << [ ]
      csv << [ "Total Sessions" ]
      csv << [ total_sessions.to_s ]
      csv << [ ]


      csv << [ "Pageviews by Page" ]


      typed_pageview_headings = current_user_type_hash.keys.sort.map do |key|
        "Page Views (#{current_user_type_hash[key]})"
      end

      csv << ([ "Path", "Total Page Views" ] + typed_pageview_headings)

      page_views_table.rows.each do |row|
        typed_pageviews = current_user_type_hash.keys.sort.map do |key|
          row[key] || 0
        end

        csv << ([ row[:page_path], row[:page_views] ] + typed_pageviews)
      end
    end
  end
end
