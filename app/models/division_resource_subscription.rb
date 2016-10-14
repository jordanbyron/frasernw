class DivisionResourceSubscription < ActiveRecord::Base
  belongs_to :division
  has_many :specializations
end
