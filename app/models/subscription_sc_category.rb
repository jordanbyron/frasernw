class SubscriptionScCategory < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :sc_category
end