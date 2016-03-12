class CreateSeedUsers < ServiceObject
  def call
    raise "These credentials are checked into git!" if Rails.env.production?

    Division.all.each do |division|

      ["admin", "user"].each do |role|
        User.seed(
          name: "#{Division.name} Test #{User::ROLE_LABELS[role]}",
          email: "#{division.name.downcase.gsub(/\W/, "")}#{role}@pathwaysbc.ca",
          password: ENV['DEMO_DATABASE_PASSWORD'],
          role: role,
          division_id: division.id
        )
      end
    end

    User.seed(
      name: "Fraser Northwest Test Super Administrator",
      email: "frasernorthwestsuper@pathwaysbc.ca",
      password: ENV['DEMO_DATABASE_PASSWORD'],
      role: "super",
      division_id: 1
    )
  end
end
