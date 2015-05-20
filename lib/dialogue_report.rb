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
  def self.users
    period = {
      start_month: Month.new(2014, 1),
      end_month: Month.new(2014, 12)
    }

    abstract_users = Reporter::Users.time_series(
      period.merge(min_sessions: 0)
    )
    users = CSVReport::Users.exec(
      abstract_users,
      "Users"
    )

    abstract_min_five = Reporter::Users.time_series(
      period.merge(min_sessions: 5)
    )
    min_five = CSVReport::Users.exec(
      abstract_min_five,
      "Users (> 5 Sessions)"
    )

    abstract_min_ten = Reporter::Users.time_series(
      period.merge(min_sessions: 10)
    )
    min_ten = CSVReport::Users.exec(
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
