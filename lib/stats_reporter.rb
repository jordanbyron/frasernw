class StatsReporter

  # Complication: there are more permutations of our three analytics variables than there are unique user ids
  def self.users(time_options)
    response = AnalyticsApiAdapter.get({
      metrics: [
        "ga:pageviews",
        "ga:sessions"
      ].join(","),
      dimensions: [
        "ga:customVarValue1",
        "ga:customVarValue2",
        "ga:customVarValue3"
      ].join(",")
    }.merge(build_time_options(time_options)))

    # division is the first of current users divisions (what does this mean in terms of the domain?)
    # type mask is stored on the user model (what does this mean in terms of domain?)
    rows = response.map do  |row|
      {
        id:           row["ga:customVarValue1"].to_i,
        type_key:     row["ga:customVarValue2"].to_i,
        division_id:  row["ga:customVarValue3"].to_i,
        page_views:   row["ga:pageviews"].to_i,
        sessions:     row["ga:sessions"].to_i
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
        page_views: 0,
        sessions: 0
      }
      duplicate_rows.each do |row|
        compound_row[:type_key].unique_push row[:type_key]
        compound_row[:division_id].unique_push row[:division_id]
        compound_row[:page_views] += row[:page_views]
        compound_row[:sessions] += row[:sessions]
      end

      # stash that compound row to put back into the array later
      compound_rows << compound_row
    end

    rows + compound_rows
  end

  def self.divisions(time_options)
  end

  def self.account_types(time_options)
  end

  # 'visits'
  def self.sessions(time_options)
    response = AnalyticsApiAdapter.get({
      metrics: "ga:sessions"
    }.merge(build_time_options(time_options)))
  end

  def self.page_views(time_options)
    response = AnalyticsApiAdapter.get({
      metrics: "ga:pageviews"
    }.merge(build_time_options(time_options)))
  end

  def self.build_time_options(time_options={})
    if time_options[:month].present?
      {
        start_date: time_options[:month].start_date,
        end_date: time_options[:month].end_date
      }
    elsif time_options[:start_date].present? && time_options[:end_date].preset?
      time_options
    else
      {
        start_date: Date.civil(2009, 1, 1),
        end_date:   Date.now
      }
    end
  end
end
