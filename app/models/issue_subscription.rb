class IssueSubscription < ActiveRecord::Base
  belongs_to :subscriber, foreign_key: "user_id", class_name: "User"
  belongs_to :issue
end
