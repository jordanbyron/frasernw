class DivisionalResourceSubscription < ActiveRecord::Base
  attr_accessible :division_id, :specialization_id

  belongs_to :division
  belongs_to :specialization
end
