class SubscriptionDivision < ActiveRecord::Base
  belongs_to :division
  belongs_to :subscription
end
