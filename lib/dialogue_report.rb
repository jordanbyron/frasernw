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
    user_type_users = CSVReport::Users.exec(
      start_month: Month.new(2014, 1),
      end_month: Month.new(2014, 12)
    )

    CSVReport::Service.new(
      "#{FOLDER_PATH}/users.csv",
      user_type_users
    ).exec
  end
end
