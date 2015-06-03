# Generates the CSVs for the dialogue report
class DialogueReport
  attr_reader :timestamp

  PERIOD = {
    start_month: Month.new(2014, 4),
    end_month: Month.new(2015, 4)
  }

  def initialize
    @timestamp = DateTime.now.to_s
  end

  def exec #to generate the mother of all reports
    visitor_accounts
    page_views
    sessions
    average_page_view_duration
    average_session_duration
    specialty_visitors
    specialty_page_views
    resource_visitors
    resource_page_views
    specialist_waittimes
    clinic_waittimes
    clinic_metrics
    specialist_metrics
    feedback_metrics
  end

  ### Each method below should generate a different file for the report
  ### and be called in the method above

  ### "Number of accounts who make a visit"
  ### "Number of accounts who make more than 5 visits"
  ### "Number of accounts who make more than 10 visits"
  ### "Number of visitors to Pathways by user category"
  def visitor_accounts
    tables = []

    tables << Analytics::CsvPresenter.exec({
      metric: :visitor_accounts,
      title: "Visitor Accounts"
    }.merge(PERIOD))

    tables << Analytics::CsvPresenter.exec({
      metric: :visitor_accounts,
      min_sessions: 5,
      title: "Visitor Accounts (> 5 Sessions)"
    }.merge(PERIOD))

    tables << Analytics::CsvPresenter.exec({
      metric: :visitor_accounts,
      min_sessions: 10,
      title: "Visitor Accounts (> 10 Sessions)"
    }.merge(PERIOD))

    write_tables(tables, "visitor_accounts")
  end

  # "Number of page views by visit by user category"
  def page_views
    table = Analytics::CsvPresenter.exec({
      metric: :page_views,
      title: "Page Views"
    }.merge(PERIOD))

    write_tables([table], "page_views")
  end

  # "Number of visits to pathways by user category"
  def sessions
    table = Analytics::CsvPresenter.exec({
      metric: :sessions,
      title: "Sessions"
    }.merge(PERIOD))

    write_tables([table], "sessions")
  end

  # "Average time per page view by user category"
  def average_page_view_duration
    table = Analytics::CsvPresenter.exec({
      metric: :average_page_view_duration,
      title: "Average time per page view"
    }.merge(PERIOD))

    write_tables([table], "average_page_view_duration")
  end

  # "Average time per visit by user category
  def average_session_duration
    table = Analytics::CsvPresenter.exec({
      metric: :average_session_duration,
      title: "Average time per session"
    }.merge(PERIOD))

    write_tables([table], "average_session_duration")
  end

  # "Number of visitors by specialty by user category"
  def specialty_visitors
    tables = for_divisions({
      metric: :visitor_accounts,
      dimensions: [:specialty, :user_type_key],
      title: "Specialty Visitor Accounts"
    }.merge(PERIOD))

    write_tables(tables, "specialty_visitors")
  end

  def specialty_page_views
    tables = for_divisions({
      metric: :page_views,
      dimensions: [:specialty, :user_type_key],
      title: "Specialty Page Views"
    }.merge(PERIOD))

    write_tables(tables, "specialty_page_views")
  end

  def resource_visitors
    tables = for_divisions({
      metric: :visitor_accounts,
      dimensions: [:resource, :user_type_key],
      title: "Resource Visitor Accounts",
    }.merge(PERIOD))

    write_tables(tables, "resource_visitors")
  end

  def resource_page_views
    tables = for_divisions({
      metric: :page_views,
      dimensions: [:resource, :user_type_key],
      title: "Resource Page Views",
    }.merge(PERIOD))

    write_tables(tables, "resource_page_views")
  end

  def specialist_waittimes
    table = CsvReport::Presenters::Waittimes.new(Specialist).exec

    write_tables([table], "specialist_waittimes")
  end

  def clinic_waittimes
    table = CsvReport::Presenters::Waittimes.new(Clinic).exec

    write_tables([table], "specialist_waittimes")
  end

  def clinic_metrics
    Metrics::ClinicMetrics.new(all: true, folder_path: folder_path).to_csv_file
  end

  def specialist_metrics
    Metrics::ClinicMetrics.new(all: true, folder_path: folder_path).to_csv_file
  end

  def feedback_metrics
    Metrics::FeedbackMetrics.new(folder_path).to_csv_file
  end

  def entity_metrics
    Metrics::EntityMetrics.new(Division.all, folder_path).to_csv_file
  end

  def for_divisions(config)
    tables = []

    tables << Analytics::CsvPresenter.exec(
      config.merge(title: "#{config[:title]}, All Divisions")
    )

    Division.all.each do |division|
      tables << Analytics::CsvPresenter.exec(
        config.merge(title: "#{config[:title]}, Division: #{division.name}", division_id: division.id)
      )
    end

    tables
  end

  def safe_timestamp
    @safe_timestamp ||= @timestamp.to_s.safe_for_filename
  end

  def folder_path
    @folder_path ||= Rails.root.join('reports','dialogue', safe_timestamp).to_s
  end

  def write_tables(tables, filename)
    FileUtils.ensure_folder_exists folder_path

    CSVReport::Service.new(
      "#{folder_path}/#{filename}.csv",
      *tables
    ).exec
  end
end
