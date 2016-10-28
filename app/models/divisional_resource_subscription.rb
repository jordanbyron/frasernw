class DivisionalResourceSubscription < ActiveRecord::Base
  attr_accessible :division_id, :nonspecialized, :specialization_ids

  belongs_to :division
  belongs_to :specialization
end
