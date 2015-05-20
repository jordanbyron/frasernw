class DialogueReport
  FOLDER_PATH = Rails.root.join('reports','dialogue','latest').to_s

  def self.exec
    users
  end

  ### Each method below should generate a different file for the report
  ### and be called in the method above

  def self.users
    user_type_users = CSVReport::UserTypeUsers.exec(
      start_month: Month.new(2014, 1),
      end_month: Month.new(2014, 12)
    )

    # division_users = CSVReport::DivisionUsers.exec(
    #   start_month: Month.new(2014, 1),
    #   end_month: Month.new(2014, 12)
    # )

    CSVReport::Service.new(
      "#{FOLDER_PATH}/users.csv",
      user_type_users
    )
  end
end
