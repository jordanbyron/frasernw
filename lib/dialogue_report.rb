class DialogueReport
  FOLDER_PATH = Rails.root.join('reports','dialogue','latest').to_s

  def self.exec
    users
  end

  ### Each method below should generate a different file for the report
  ### and be called in the method above


  ### "Number of accounts who make a visit"
  ### "Number of accounts who make more than 5 visits"
  ### "Number of accounts who make more than 10 visits"
  ### "Number of visitors to Pathways by user category"
  # TODO cleanup this method
  def self.users
    period = {
      start_month: Month.new(2014, 1),
      end_month: Month.new(2014, 12)
    }

    abstract_users = Reporter::ByDivisionAndUserType.time_series(
      :users,
      period
    )
    users = CSVReport::ByDivisionAndUserType.exec(
      abstract_users,
      "Users"
    )

    abstract_min_five = Reporter::ByDivisionAndUserType.time_series(
      :users_min_5_sessions,
      period
    )
    min_five = CSVReport::ByDivisionAndUserType.exec(
      abstract_min_five,
      "Users (> 5 Sessions)"
    )

    abstract_min_ten = Reporter::ByDivisionAndUserType.time_series(
      :users_min_10_sessions,
      period
    )
    min_ten = CSVReport::ByDivisionAndUserType.exec(
      abstract_min_ten,
      "Users (> 10 Sessions)"
    )

    CSVReport::Service.new(
      "#{FOLDER_PATH}/users.csv",
      users,
      min_five,
      min_ten
    ).exec
  end
end
