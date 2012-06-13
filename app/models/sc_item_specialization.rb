class ScItemSpecialization < ActiveRecord::Base
  belongs_to  :sc_item
  belongs_to  :specialization
end
