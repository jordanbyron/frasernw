# Generates the CSVs for the dialogue report
class DialogueReport
  FOLDER_PATH = Rails.root.join('reports','dialogue','latest').to_s
  PERIOD = {
    start_month: Month.new(2014, 4),
    end_month: Month.new(2015, 4)
  }

  def self.exec
    users
    page_views
    sessions
    average_page_view_duration
    average_session_duration
  end

  ### Each method below should generate a different file for the report
  ### and be called in the method above

  ### "Number of accounts who make a visit"
  ### "Number of accounts who make more than 5 visits"
  ### "Number of accounts who make more than 10 visits"
  ### "Number of visitors to Pathways by user category"
  def self.users
    tables = []

    tables << Analytics::CsvPresenter.exec({
      metric: :users,
      title: "Users"
    }.merge(PERIOD))

    tables << Analytics::CsvPresenter.exec({
      metric: :users_min_5_sessions,
      title: "Users (> 5 Sessions)"
    }.merge(PERIOD))

    tables << Analytics::CsvPresenter.exec({
      metric: :users_min_10_sessions,
      title: "Users (> 10 Sessions)"
    }.merge(PERIOD))

    write_tables(tables, "users")
  end

  # "Number of page views by visit by user category"
  def self.page_views
    table = Analytics::CsvPresenter.exec({
      metric: :page_views,
      title: "Page Views"
    }.merge(PERIOD))

    write_tables([table], "page_views")
  end

  # "Number of visits to pathways by user category"
  def self.sessions
    table = Analytics::CsvPresenter.exec({
      metric: :sessions,
      title: "Sessions"
    }.merge(PERIOD))

    write_tables([table], "sessions")
  end

  # "Average time per page view by user category"
  def self.average_page_view_duration
    table = Analytics::CsvPresenter.exec({
      metric: :average_page_view_duration,
      title: "Average time per page view"
    }.merge(PERIOD))

    write_tables([table], "average_page_view_duration")
  end

  # "Average time per visit by user category
  def self.average_session_duration
    table = Analytics::CsvPresenter.exec({
      metric: :average_session_duration,
      title: "Average time per session"
    }.merge(PERIOD))

    write_tables([table], "average_session_duration")
  end

  def self.write_tables(tables, filename)
    CSVReport::Service.new(
      "#{FOLDER_PATH}/#{filename}.csv",
      *tables
    ).exec
  end
end
