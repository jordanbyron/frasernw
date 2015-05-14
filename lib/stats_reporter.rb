# Standard set of stats queries
class StatsReporter
  # requires at least start date and end date
  def self.users(options)
    response = AnalyticsApiAdapter.get({
      metrics: [:pageviews, :sessions],
      dimensions: [:user_id, :user_type_key, :division_id]
    }.merge(options))

    # unique based on user id
    # TODO extract to a generic service and test

    # find the duplicate ids
    duplicate_ids = rows.map do |row|
      row[:user_id]
    end.select do |id|
      rows.count{|row| row[:user_id] == id} > 1
    end.uniq

    compound_rows = []

    # for each duplicate id:
    duplicate_ids.each do |id|
      # grab the relevant rows

      duplicate_rows = rows.select{ |row| row[:user_id] == id }

      # delete them from the array
      rows.reject!{ |row| duplicate_rows.include? row }

      # mash them together
      compound_row = {
        user_id:     id,
        user_type_key: [],
        division_id: [],
        page_views: 0,
        sessions: 0
      }
      duplicate_rows.each do |row|
        compound_row[:user_type_key].unique_push row[:type_key]
        compound_row[:division_id].unique_push row[:division_id]
        compound_row[:page_views] += row[:page_views]
        compound_row[:sessions] += row[:sessions]
      end

      # stash that compound row to put back into the array later
      compound_rows << compound_row
    end

    rows + compound_rows
  end

  def self.divisions(options)
  end

  def self.account_types(options)
  end

  # 'visits'
  def self.sessions(options)
    AnalyticsApiAdapter.get({
      metrics: [:sessions],
    }.merge(options))
  end

  def self.page_views(options)
    AnalyticsApiAdapter.get({
      metrics: [:page_views],
    }.merge(options))
  end

  def self.page_views_by_page(options)
    AnalyticsApiAdapter.get({
      metrics: [:page_views],
      dimensions: [:page_path]
    }.merge(options))
  end
end
