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


if !Division.any?
  divisions = Division.create([{name: "Vancouver"}, {name: "Burnaby"} ])
end

if !User.any?
  user = User.new(:name => "First User", :type_mask => 4, :role => "super")
  user.user_divisions.build(:division_id => Division.where("name = (?)", "Vancouver").first.id)
  user.password = "test1234"
  user.email = "test@test.com"
  user.saved_token = "totallyfake"
  user.save validate: false
end