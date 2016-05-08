class PageviewsByUserTemp < ServiceObject

  def call
    mission_abbotsford = Division.find(5)

    body_rows = Analytics::ApiAdapter.get({
      metrics: [:page_views],
      start_date: Month.prev.start_date,
      end_date: Month.prev.end_date,
      dimensions: [:user_id]
    }).reject do |row|
      row[:user_id] == "-1"
    end.map do |row|
      {
        user: User.safe_find(row[:user_id]),
        page_views: row[:page_views]
      }
    end.select do |row|
      row[:user].known? &&
        row[:user].divisions.include?(mission_abbotsford) &&
        !row[:user].admin_or_super?
    end.sort_by do |row|
      -(row[:page_views].to_i)
    end.map do |row|
      [
        row[:user].id,
        row[:user].name,
        row[:page_views]
      ]
    end

    QuickSpreadsheet.call(
      title: "Page Views by Mission Abbotsford Non-admin Users (March 2016)",
      header_row: [
        "ID",
        "Name",
        "Page Views"
      ],
      body_rows: body_rows
    )
  end
end
