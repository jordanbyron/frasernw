# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

["A", "B", "C", "D"].each {|level|
  Evidence.create(level: level)
} unless Evidence.any?

unless Division.any?
  divisions = Division.create([{name: "Vancouver"}, {name: "Burnaby"} ])
end

unless User.any?
  user = User.new(:name => "Test Super Admin User", :type_mask => 4, :role => "super")
  user.user_divisions.build(:division_id => Division.where("name = (?)", "Vancouver").first.id)
  user.password = "test1234"
  user.email = "testsuperadmin@test.com"
  user.saved_token = "totallyfake"
  user.save validate: false


  user = User.new(:name => "Test User", :type_mask => 4, :role => "user")
  user.user_divisions.build(:division_id => Division.where("name = (?)", "Vancouver").first.id)
  user.password = "test1234"
  user.email = "testuser@test.com"
  user.saved_token = "totallyfake"
  user.save validate: false
end

unless NewsItem.any?
  NewsItem.create(title: "Breaking News Item", body: "This is the body of a breaking news item!", owner_division_id: divisions.first, type_mask: NewsItem::TYPE_BREAKING, start_date: Date.yesterday, end_date: Date.tomorrow)
  NewsItem.create(title: "Divisional News Item", body: "This is the body of a divisional news item!", owner_division_id: divisions.first, type_mask: NewsItem::TYPE_DIVISIONAL,  start_date: Date.yesterday, end_date: Date.tomorrow)
end