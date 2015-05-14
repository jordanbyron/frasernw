class StatsReporter

  # Complication: there are more permutations of our three analytics variables than there are unique user ids
  def self.users(start_date, end_date)
    response = AnalyticsApiAdapter.get(
      start_date: start_date,
      end_date: end_date,
      metrics: "ga:pageviews",
      dimensions: [
        "ga:customVarValue1",
        "ga:customVarValue2",
        "ga:customVarValue3"
      ].join(",")
    )

    # division is the first of current users divisions (what does this mean in terms of the domain?)
    # type mask is stored on the user model (what does this mean in terms of domain?)
    rows = response.map do  |row|
      {
        id:           row["ga:customVarValue1"].to_i,
        type_key:     row["ga:customVarValue2"].to_i,
        division_id:  row["ga:customVarValue3"].to_i,
        page_views:   row["ga:pageviews"].to_i
      }
    end

    # unique based on user id
    # TODO test

    # find the duplicate ids
    duplicate_ids = rows.map do |row|
      row[:id]
    end.select do |id|
      rows.count{|row| row[:id] == id} > 1
    end.uniq

    compound_rows = []

    # for each duplicate id:
    duplicate_ids.each do |id|
      # grab the relevant rows

      duplicate_rows = rows.select{ |row| row[:id] == id }

      # delete them from the array
      rows.reject!{ |row| duplicate_rows.include? row }

      # mash them together
      compound_row = {
        id:     id,
        type_key: [],
        division_id: [],
        page_views: 0
      }
      duplicate_rows.each do |row|
        compound_row[:type_key].unique_push row[:type_key]
        compound_row[:division_id].unique_push row[:division_id]
        compound_row[:page_views] += row[:page_views]
      end

      # and throw the resulting compound row back into the array
      compound_rows << compound_row
    end

    rows + compound_rows
  end

  def self.users_for_month(month)
    users(month.start_date, month.end_date)
  end
end
