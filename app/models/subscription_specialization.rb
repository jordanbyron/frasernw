class SubscriptionSpecialization < ActiveRecord::Base
  belongs_to :specialization
  belongs_to :subscription
end
